// Copyright Mechanist Games

Shader "Mechanist/03 - Water, Fall"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_Refraction("Refraction", Range (0.0,0.3)) = 0.15
		_Darkness("Darkness", Range (0.333,1)) = 0.666
		
		_Depth("Depth (Meters)", Float) = 1
		_WaveControl ("Wave Length (xy), Speed (z)", Vector) = (0.25, 0.25, 1, 0.1)
		
		_Clarity("Color", Range (0,0.666)) = 0.333
		
		_NormalSpeed ("Water UV Speed, (xy), (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		_Fresnel("Fresnel", Range (1,5)) = 3
		_Reflection("Reflection", Range (0,1)) = 0.5
		
		_FoamTiling("Foam Tiling (5.0)", Float) = 5
		_FoamNormal("Foam Normals", Range (0.01,0.05)) = 0.03
		
		_WaterTex ("Water Texture", 2D) = "white" { }
		_CubeMap ("Reflection Cubemap", CUBE) = "" {}
		_GroundTex("Ground Texture", 2D) = "white" {}
		
		_TransparencyLM ("Lightmap Transparency", 2D ) = "white"{}
	}
	
	Subshader
	{
		LOD 100
		
		Tags {
			"Queue" = "Transparent-1"
			//"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		Cull Back
      		Fog {Mode Off}
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                half4 vertex : POSITION;
                half4 color : COLOR;
                half2 texcoord0 : TEXCOORD0;
                half2 texcoord1 : TEXCOORD1;
            };
            
			struct vertShader {
		    	half4 pos : SV_POSITION;
			    float2 uv2 : TEXCOORD0;
			    float2 uv3 : TEXCOORD1;
		    	float2 uv4 : TEXCOORD2;
		    	float2 uv5 : TEXCOORD3;
		    	half4 cam : TEXCOORD4;
           		half4 dep : TEXCOORD5;
		    	half4 vtc : TEXCOORD6;
	   			fixed fog : TEXCOORD7;
		    };
			
			uniform sampler2D _WaterTex;
			uniform sampler2D _GroundTex;
			uniform samplerCUBE _CubeMap;
			uniform half4 _WaterTex_ST;
			
			// properties
			uniform float _TilesPerMeter;
			uniform float4 _WaveControl;
			uniform float4 _NormalSpeed;
			uniform float _Depth;
			uniform float _Reflection;
			
			uniform fixed _Clarity;
			uniform fixed _Darkness;
			uniform fixed _Refraction;
			uniform fixed _Fresnel;
			uniform fixed _FoamNormal;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV = worldVertex.xz * _TilesPerMeter;
				
				// viewDir, depthHgt
			    half3 cam = half3 (worldVertex - _WorldSpaceCameraPos);
			    half refl = 0.333 + 0.333 * _Reflection * v.color.r;
			    refl = lerp ( 1, refl, v.color.a);
			    o.cam = half4(cam,refl);
			    
				// waves, reflect, depthUV
				half4 dep;
				half waves = sin(_Time.y * _WaveControl.z + _WaveControl.x * worldVertex.x + _WaveControl.y * worldVertex.z);
				waves += sin(_Time.y * _WaveControl.z + _WaveControl.x * worldVertex.z * 1.3);
				dep.r = (waves * 0.3 + 1.5) * v.color.b;
				dep.g = 0.25 + 0.75 * v.color.r;
				
			    // UV calculation
			    float3 depthDir = normalize (ObjSpaceViewDir(v.vertex));
			    float2 depthMult = v.color.r * v.color.b * _Depth;
				float2 depthUV = - (depthDir.xz + waves * _WaveControl.w * depthDir.xz) * depthMult * _TilesPerMeter;
				dep.ba = depthUV;
				o.dep = dep;
				
				// vertex colors
				o.vtc = v.color;
			    
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv2 = worldUV;
				o.uv3 = inlineLightmapTransform ( v.texcoord1 );
				o.uv4 = v.texcoord0 * 17 + half2 ( _Time.xx * _NormalSpeed.xy * 0.1);
				o.uv5 = v.texcoord0 * 23 + half2 ( _Time.xx * _NormalSpeed.zw * 0.1);
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
			    return o;
			}
						
			inline half3 inlineReflection ( half3 cam, half4 vtc, half3 norms) {
				half3 reflDir = cam - half3(norms.r,1,norms.g) * vtc.a * _Fresnel;
				half3 reflection = texCUBE(_CubeMap, reflDir);
				return reflection;
			}
			
			inline half inlineEdgeFoam ( half3 norms, half2 uv ) {
				half2 foamNrm = uv + norms.rg * _FoamNormal;
				half edgefoam = tex2D(_WaterTex, foamNrm).b;
				return edgefoam;
			}
			
			half4 frag (vertShader i) : SV_Target {
			
			    // normal calc
				half3 norms = tex2D(_WaterTex, i.uv4).rgb + tex2D(_WaterTex, i.uv5).rgb - half3(1,1,0);
			    half4 ground = tex2D(_GroundTex, i.uv2);
				fixed3 outcolor = _Gbl_Wat;
				
			    // inline functions
				fixed3 reflection = inlineReflection ( i.cam, i.vtc, norms );
				fixed edgefoam = inlineEdgeFoam ( norms, i.uv4);
				half3 lightmap = inlineLightmapBasic ( i.uv3 );
				
				// combine
				outcolor = lerp ( outcolor, _Darkness * ground, 1 - _Clarity * i.dep.g );
				outcolor += edgefoam * i.vtc.g;
				
			    // water edge
			    half smoother = ( 1 + ground.a ) * i.dep.r;
				half waterEdge = step (0.9, smoother);
				outcolor = lerp ( ground.rgb, outcolor, waterEdge);
				outcolor -= 0.25 * i.dep.r * (1 - waterEdge);
				
				// combine
				outcolor *= lightmap;
				outcolor = lerp ( outcolor, reflection, waterEdge * i.cam.w );
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
			    return half4(outcolor, i.vtc.a);
			}
			ENDCG
		}
	}
	//Fallback "VertexLit"
 }