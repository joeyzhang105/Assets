// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/Ocean"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (XY,ZW)", Vector) = (0.01,0.01,0.01,0.01)
		_NormalSpeed ("Ripples: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_Reflection ("Reflection Amount", Float) = 0.1
		_ReflectionScale ("Reflection Scale", Float) = 0.1
		
		_WaterTex ("Water Texture", 2D) = "white" { }
		_Specular ("Specular Texture", 2D) = "white" { }
		_CubeTex ("Reflection Texture", 2D) = "white" {}
		_RimTintAmt("Rim Tint Amount", Range(0,1)) = 0.5
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
			    float2 uv2 : TEXCOORD1;
			    float2 uv3 : TEXCOORD2;
		    	float2 uv4 : TEXCOORD3;
           		fixed col : TEXCOORD4;
		    };
			
			// resources
			uniform sampler2D _WaterTex;
			uniform sampler2D _Specular;
			uniform sampler2D _CubeTex;
			
			// properties
			uniform float4 _TilesPerMeter;
			uniform float4 _NormalSpeed;
			uniform float _WaveDist;
			uniform fixed _Reflection;
			uniform fixed _ReflectionScale;
			uniform fixed _RimTintAmt;
			
			// global properties
			uniform float3 _LightRotation;
			uniform float3 _CameraFocalPoint;
			uniform float _Curvature;
			uniform fixed3 _MappyAmbient;
			uniform fixed3 _OceanMidColor;
			uniform fixed3 _OceanRimColor;
			uniform float _OceanSize;
			uniform float _OceanSpeed;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV1 = worldVertex.xz * _TilesPerMeter.xy;
				float2 worldUV2 = worldVertex.xz * _TilesPerMeter.xz;
								
				// curvature
				float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
				
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV1 * _OceanSize + float2 ( _Time.xx * _NormalSpeed.xy) * _OceanSpeed;
				o.uv2 = worldUV2 * _OceanSize + float2 ( _Time.xx * _NormalSpeed.zw) * _OceanSpeed;
				
				// sun glow
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				o.uv4 = mul ( v.texcoord1.xy - float2(0.5,0.5), rotMat ) * 1.5 + float2(0.5,0.5);
				
				// color
				float curveTotal = (distanceX + distanceX) * _Curvature * 30;
				o.col = smoothstep(0,1,curveTotal) * _RimTintAmt;
				
				// reflection
				o.uv3 = worldUV1 * _ReflectionScale + float2(_Time.w * 0.005, _Time.w * -0.002);
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
			    // normal calc
				fixed3 outcolor = _OceanMidColor;
				fixed3 norms = tex2D(_WaterTex, i.uv1) - tex2D(_WaterTex, i.uv2);
				
			    // reflection
				fixed3 reflection = tex2D(_CubeTex, i.uv3 + norms.rg * 0.03);
				outcolor = lerp ( outcolor, reflection, _Reflection);
				
				// specular
				fixed4 spccolor = tex2D ( _Specular, i.uv4 + norms.rg * 0.03);
				outcolor += spccolor.rgb;
				
				// mix
				outcolor = lerp( outcolor,_OceanRimColor, i.col);
				
				// combine
				return fixed4( outcolor, 1 );
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }