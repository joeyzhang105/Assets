// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/UGC Under"
{
	Properties
	{
		_UGC_Curvature ("UGC Curvature", Float) = 0.001
		_TilesPerMeter ("Tiles Per Meter (XY,ZW)", Vector) = (0.01,0.01,0.01,0.01)
		_NormalSpeed ("Movement: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_CloudTex ("Cloud Texture", 2D) = "white" { }
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
			    float2 uv2 : TEXCOORD1;
			    float2 uv3 : TEXCOORD2;
           		fixed col : TEXCOORD4;
		    };
			
			// resources
			uniform sampler2D _CloudTex;
			uniform sampler2D _Specular;
			
			// properties
			uniform float4 _TilesPerMeter;
			uniform float4 _NormalSpeed;
			
			// global properties
			uniform fixed3 _WaterColor;
			uniform float3 _LightRotation;
			uniform float3 _UGC_MapCenter;
			uniform float _UGC_Curvature;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV1 = worldVertex.xz * _TilesPerMeter.xy;
				float2 worldUV2 = worldVertex.xz * _TilesPerMeter.zw;
								
				// curvature
				float3 totalDist = distance ( _UGC_MapCenter, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _UGC_Curvature;
				float distanceZ = totalDist.z * totalDist.z * _UGC_Curvature;
				v.vertex.y -= distanceX + distanceZ;
				
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV1 + float2 ( _Time.xx * _NormalSpeed.xy);
				o.uv2 = worldUV2 + float2 ( _Time.xx * _NormalSpeed.zw);
				
				// sun glow
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 cloudUV = (worldVertex.xz - _UGC_MapCenter.xz) * -0.006;
				o.uv3 = mul ( cloudUV, rotMat ) + float2(0.5,0.5);
				
				// color
				float cameraDir = normalize(_WorldSpaceCameraPos - worldVertex) * float3(0,0,_WorldSpaceCameraPos.z);
				o.col = smoothstep ( 0, 150, distance( _UGC_MapCenter + cameraDir , worldVertex ));
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
				fixed3 spccolor = tex2D ( _Specular, i.uv3);
				fixed3 wtrcolor = (_WaterColor + spccolor) * 0.5;
				fixed4 cldcolor = (tex2D(_CloudTex, i.uv1) + tex2D(_CloudTex, i.uv2)) * 0.25;
				fixed3 outcolor = wtrcolor + cldcolor.rgb;
				
				outcolor = lerp ( outcolor, spccolor, clamp(i.col + cldcolor.a, 0, 1));
				
				//outcolor.a += i.col;
				//outcolor.a = clamp ( outcolor.a, 0, 1);
				
				// combine
				return fixed4(outcolor,1);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }