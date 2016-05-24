// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist/03 - Water, Spec"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_Scale("Normal Scale (0.2)", Float) = 0.6
		_FoamTiling("Foam Scale (3.0)", Float) = 3
		
		_Darkness("Darkness", Range (0.333,1)) = 0.666
		_Depth("Depth (Meters)", Float) = 1
		_Clarity("Color", Range (0,1)) = 0.5
		
		_WaveControl ("Waves: Length (xy), Speed (z), Height (w)", Vector) = (0.3, 0.3, 1, 0.1)
		_WaveMeshHeight ( "Wave Mesh Height", Float ) = 0
		_WaveFoamBright ( "Wave Foam Brightness", Float ) = 0
		
		_NormalSpeed ("Ripples: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		_Reflect("Reflection Strength", Range (0,1)) = 0.5
		_Fresnel("Reflection Normals", Range (0,7)) = 1
		_FoamNormal("Foam Normals", Range (0.01,0.05)) = 0.03
		
		_WaterTex ("Water Texture", 2D) = "white" { }
		_FoamTex ("Foam Texture", 2D) = "white" { }
		_CubeMap ("Reflection Cubemap", CUBE) = "" {}
		_GroundTex("Ground Texture", 2D) = "white" {}
		
		_Loc_Spc_Pow ("Specular Power (~10)", Float) = 10
		_Loc_Spc_Str ("Specular Strength, Ground (~0.1)", Float) = 0.1
		_Loc_Spc_Wat ("Specular Boost, Water (~5)", Float) = 5
		
		_LightBase ("Water/Terrain Light Strength", Float) = 0.5
	}
	
	SubShader {
	
		LOD 100
		
		Tags {
			"Queue" = "Geometry"
			//"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		Pass {
		
      		Cull Back
      		Fog {Mode Off}
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
			struct vertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
		    	float2 uv3 : TEXCOORD1;
		    	float2 uv4 : TEXCOORD2;
		    	half4 cam : TEXCOORD3;
           		half4 wat : TEXCOORD4;
           		fixed3 spc : TEXCOORD5;
           		fixed fog : TEXCOORD6;
   				
				#if !defined (SHADOWS_OFF)
			   	    SHADOW_COORDS(7)
				#endif
		    };
			
			// resources
			uniform sampler2D _WaterTex;
			uniform sampler2D _FoamTex;
			uniform sampler2D _GroundTex;
			uniform samplerCUBE _CubeMap;
			uniform float4 _WaterTex_ST;
			
			// properties
			uniform float _TilesPerMeter;
			uniform float4 _WaveControl;
			uniform float4 _NormalSpeed;
			uniform float _Depth;
			uniform float _Reflect;
			uniform float _WaveMeshHeight;
			uniform float _WaveFoamBright;			
			uniform float _Clarity;
			uniform float _Scale;
			
			uniform fixed _Darkness;
			uniform fixed _LightBase;
			uniform fixed _Fresnel;
			uniform fixed _FoamNormal;
			uniform fixed _FoamTiling;
			
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			uniform half _Loc_Spc_Wat;
			
			vertShader vert ( appdata_full v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV = worldVertex.xz * _TilesPerMeter.xx;
				
				// reflection view direction
				float3 cameraDir = normalize ( WorldSpaceViewDir (v.vertex) );
			    o.cam = float4 ( worldVertex - _WorldSpaceCameraPos, v.color.b);
				
				// specular
				#ifdef QUALITY_HGH
					o.spc = _Gbl_Spc * pow ( max ( 0, dot ( reflect ( -_WorldSpaceLightPos0, half4 ( 0, 1, 0 ,0 ) ), cameraDir ) ), _Loc_Spc_Pow ) * _Loc_Spc_Str;
				#else
					o.spc = fixed3(0,0,0);
				#endif
			    
				// wave calculation
				float waves = sin(_Time.y * _WaveControl.z + _WaveControl.x * worldVertex.x + _WaveControl.y * worldVertex.z);
				waves += sin(_Time.z * _WaveControl.z * 0.666 + _WaveControl.x * worldVertex.z * 1.2);
				waves = clamp(waves * 0.5 + 0.5, 0, 1);
				
				// swizzle frag vars
				o.wat.r = (waves + 1) * v.color.b; // water edge step helper
				o.wat.g = _Clarity * v.color.r; // water clarity versus color
				o.wat.b = v.color.g * _WaveFoamBright + waves * 0.5; // foam crests brightness
				o.wat.a = lerp ( 1, _Reflect, v.color.a ); // skycube gradient transition
				
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			    
			    // texcoord Ground
				float2 depthUV = cameraDir.xz * v.color.r * v.color.b * _Depth * _TilesPerMeter;
				o.uv1 = worldUV - depthUV;
				
				// texcoord Water
				float4 waveSpeed = _NormalSpeed * _Time.x * 0.1;
				o.uv3 = worldUV * _Scale + waveSpeed.xy;
				o.uv4 = worldUV * _Scale * 1.2 + waveSpeed.zw;
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					float fogDistance = length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
					fixed fogAmount = clamp ( 1 - v.color.a + fogDistance / _FogDistMax, 0, _FogClamp );
					o.fog = fogAmount;
				#endif
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : COLOR
			{
				
			    // normal calc
				fixed3 norms = tex2D(_WaterTex, i.uv3) - tex2D(_WaterTex, i.uv4);
			    fixed4 ground = tex2D(_GroundTex, i.uv1);
				fixed3 outcolor = _Gbl_Wat;
				
				#if !defined (SHADOWS_OFF)
					fixed3 lightmap = _Gbl_Amb + _Gbl_Lgt * _LightBase * SHADOW_ATTENUATION(i);
				#else
					fixed3 lightmap = _Gbl_Amb + _Gbl_Lgt * _LightBase;
				#endif
				
			    // reflection
				fixed3 reflDir = normalize(i.cam.xyz - norms * (1-i.wat.a) * _Fresnel);
				fixed3 reflection = texCUBE(_CubeMap, reflDir);
				
			    // water edge
			    #ifndef QUALITY_LOW
			    	fixed smoother = ( 1 + ground.a ) * i.wat.r;
					fixed waterEdge = step (0.9, smoother) * i.cam.w;
				#else
					fixed waterEdge = i.cam.w;
				#endif
				
				// ground
				outcolor = lerp ( ground.rgb, outcolor, waterEdge * i.wat.g);
				
				// edge foam
				#ifdef QUALITY_HGH
					float2 foamNrm = i.uv3 * _FoamTiling + norms.rb * _FoamNormal;
					fixed3 edgefoam = tex2D(_FoamTex, foamNrm).rgb * i.wat.b;
					outcolor += edgefoam * waterEdge;
				#endif
				
				outcolor *=  lightmap;
								
				#ifdef QUALITY_HGH
					outcolor *= 1 + i.spc * (1-ground.a + waterEdge * _Loc_Spc_Wat);
				#endif
				
				outcolor = lerp ( outcolor, reflection, waterEdge * i.wat.a );
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return fixed4( outcolor, 1 );
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }