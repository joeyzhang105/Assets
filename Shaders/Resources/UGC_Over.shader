// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/UGC Over"
{
	Properties
	{
		_UGC_Curvature ("UGC Curvature", Float) = 0.001
		_TilesPerMeter ("Tiles Per Meter (XY,ZW)", Vector) = (0.01,0.01,0.01,0.01)
		_NormalSpeed ("Movement: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_CloudTex ("Cloud Texture", 2D) = "white" { }
		_Specular ("Specular Texture", 2D) = "white" { }
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Transparent+2"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		Pass {
      		Cull Back
      		Fog {Mode Off}
      		ZWrite Off
      		Blend SrcAlpha OneMinusSrcAlpha
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
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
			    float2 uv4 : TEXCOORD3;
           		fixed col : TEXCOORD4;
           		fixed4 vtc : TEXCOORD5;
		    };
			
			// resources
			uniform sampler2D _CloudTex;
			uniform sampler2D _Specular;
			
			// properties
			uniform float4 _TilesPerMeter;
			uniform float4 _NormalSpeed;
			
			// global properties
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
				o.uv4 = worldVertex.xz * 0.015 - float2 ( _Time.x * 0.03, _Time.x * -0.03 );
				
				// sun glow
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 cloudUV = (worldVertex.xz - _UGC_MapCenter.xz) * fixed2(-0.008, -0.008);
				o.uv3 = mul ( cloudUV, rotMat ) + float2(0.5,0.5);
				
				// color
				float cameraDir = normalize(_WorldSpaceCameraPos - worldVertex) * float3(0,0,_WorldSpaceCameraPos.z);
				o.col = smoothstep ( 150, 50, distance( _UGC_MapCenter + cameraDir , worldVertex ));
				
				o.vtc = v.color;
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
				fixed4 cldalpha = tex2D(_CloudTex, i.uv1) + tex2D(_CloudTex, i.uv2);
				fixed4 cldcolor = tex2D(_CloudTex, i.uv4) * 0.5 + cldalpha * 0.25;
				
				fixed4 outcolor = (cldcolor + tex2D ( _Specular, i.uv3 )) * 0.55;
				
				outcolor.a = smoothstep ( 0, 1.1, cldalpha.a ) * i.col * i.vtc.a;
				
				return outcolor;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }