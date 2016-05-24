// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/UGC Ocean"
{
	Properties
	{
		_WaterTex ("Water Texture", 2D) = "white" { }
		_Specular ("Specular Texture", 2D) = "white" { }
		_WaterColor ("Ocean Color", Color) = (1,1,1,1)
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Geometry"
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
			
			//#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord1 : TEXCOORD0;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    fixed fad : TEXCOORD1;
		    };
			
			// resources
			uniform sampler2D _WaterTex;
			uniform sampler2D _Specular;
			uniform sampler2D _CubeTex;
			
			// properties
			uniform fixed3 _WaterColor;
			uniform fixed3 _OceanMidColor;
			uniform fixed3 _OceanRimColor;
			uniform fixed3 _OceanLocalColor;
			uniform float4 _TilesPerMeter;
			uniform float4 _NormalSpeed;
			uniform float _WaveDist;
			uniform fixed _Reflection;
			uniform fixed _ReflectionScale;
			
			// global properties
			uniform float3 _LightRotation;
			uniform float3 _UGC_MapCenter;
			uniform float _Curvature;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV1 = worldVertex.xz * _TilesPerMeter.xy;
				float2 worldUV2 = worldVertex.xz * _TilesPerMeter.xz;
								
				// curvature
				float3 totalDist = distance ( _UGC_MapCenter, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
				
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				// sun glow
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				o.uv1 = mul ( v.texcoord1.xy - float2(0.5,0.5), rotMat ) * 1.5 + float2(0.5,0.5);
				
				// reflection
				float cameraDir = normalize(_WorldSpaceCameraPos - worldVertex) * float3(0,0,_WorldSpaceCameraPos.z);
				o.fad = smoothstep ( 50, 150, distance( _UGC_MapCenter + cameraDir , worldVertex ));
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
				// specular
				fixed3 spccolor = tex2D ( _Specular, i.uv1);
				
				fixed3 outcolor = lerp ( _WaterColor, spccolor, i.fad);
				
				// combine
				return fixed4(outcolor, 1 );
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }