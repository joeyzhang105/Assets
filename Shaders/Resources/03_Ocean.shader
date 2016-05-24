// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist/03 - Ocean"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		
		_Reflection ("Reflection Amount", Range (1,0)) = 0.5
		_WaveSpeed ("Wave Speed XYZ", Vector) = (1, 1, 1, 0)
		_WaveLength ("Wave Length XYZ", Vector) = (10, 10, 10, 0)
		_WaveHeight ("Wave Height XYZ", Vector) = (1, 1, 1, 0)
		_WaveDist("Wave Fade Distance", Range (40,100)) = 70
		
		_Fresnel("Fresnel", Range (1,7)) = 4
		_FoamBright ("Foam Brightness", Range (0.5,1)) = 0.75
		_FoamTiling("Foam Tiling (5.0)", Float) = 5
		_FoamNormal("Foam Normals", Range (0.01,0.05)) = 0.03
		_FoamCutoff("Foam Cut Off", Range (-3,0)) = -1.5
		_NormalSpeed ("Ripples: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_WaterTex ("Water Texture", 2D) = "white" { }
		_FoamTex ("Foam Texture", 2D) = "white" { }
		_CubeMap ("Reflection Cubemap", CUBE) = "" {}
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Transparent-3"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass {
      		Cull Back
      		Fog {Mode Off}
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    float2 uv2 : TEXCOORD1;
			    float2 uv3 : TEXCOORD2;
		    	half4 cam : TEXCOORD4;
		    	float4 nrm : TEXCOORD6;
	   			fixed fog : TEXCOORD7;
		    };
			
			// resources
			uniform sampler2D _WaterTex;
			uniform sampler2D _FoamTex;
			uniform samplerCUBE _CubeMap;
			
			// properties
			uniform float _TilesPerMeter;
			uniform float4 _WaveSpeed;
			uniform float4 _WaveLength;
			uniform float4 _WaveHeight;
			uniform float4 _NormalSpeed;
			uniform fixed _FoamBright;
			uniform float _WaveDist;
			
			uniform float _Reflection;
			uniform fixed _Fresnel;
			uniform fixed _FoamNormal;
			uniform float _FoamTiling;
			uniform float _FoamCutoff;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV = worldVertex.xz * _TilesPerMeter;
			    
				// waves
				float waves1 = sin(_Time.y * _WaveSpeed.x + _WaveLength.x * worldVertex.x) * _WaveHeight.x;
				float waves2 = sin(_Time.y * _WaveSpeed.y + _WaveLength.y * worldVertex.z) * _WaveHeight.y;
				float waves3 = sin(_Time.y * _WaveSpeed.z + 0.5 * _WaveLength.z * worldVertex.x + 0.5 * _WaveLength.z * worldVertex.z) * _WaveHeight.z;
				float waveTotal = smoothstep ( _FoamCutoff, 5, waves1 + waves2 + waves3 ) * _FoamBright;
				
				// vertex & normals
				float waveDist = clamp ( v.color.a * distance ( _WorldSpaceCameraPos, worldVertex ) / _WaveDist, 0, 1);
				v.vertex.y += waveDist * (waves1 + waves2 + waves3);
				v.normal.x -= waveDist * (waves1 + waves3);
				v.normal.z -= waveDist * (waves2 + waves3);
				o.nrm = float4 (v.normal, waveTotal  * v.color.a);
				
				// viewDir
				half3 camDir = (worldVertex - _WorldSpaceCameraPos);
				half reflAmt = 1 - _Reflection * waveDist * ( v.color.a );
				o.cam = half4 (camDir, reflAmt );
				
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV + float2 ( _Time.xx * _NormalSpeed.xy * 0.1);
				o.uv2 = worldUV * 1.3 + float2 ( _Time.xx * _NormalSpeed.zw * 0.1);
				o.uv3 = worldUV * _FoamTiling + float2 ( _Time.xx * _NormalSpeed.yx * 0.5);
				
				// fog
				#ifdef QUALITY_HGH
					float fogDistance = length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
					fixed fogAmount = clamp ( 1 - v.color.a + fogDistance / _FogDistMax, 0, _FogClamp );
					o.fog = fogAmount;
				#endif
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
			    // normal calc
				fixed3 outcolor = _Gbl_Wat;
				fixed3 norms = (tex2D(_WaterTex, i.uv1) - tex2D(_WaterTex, i.uv2)) * i.nrm.xyz;
				
			    // reflection
				fixed3 reflDir = i.cam.xyz - norms * _Fresnel;
				fixed3 reflection = texCUBE(_CubeMap, reflDir);
				outcolor = lerp ( outcolor, reflection, i.cam.w);
				
				// foam
				float2 foamNrm = i.uv3 + norms.rg * _FoamNormal + i.nrm.xz * 0.2;
				fixed edgefoam = tex2D(_FoamTex, foamNrm).b * 2;
				outcolor = lerp ( outcolor, 1, edgefoam * i.nrm.w );
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return fixed4(outcolor,1);
			}
			ENDCG
		}
	}
	//Fallback "VertexLit"
 }