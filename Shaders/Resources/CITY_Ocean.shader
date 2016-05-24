// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist CITY/Ocean"
{  
	Properties
	{
		_ShadowSize ("Shadow Size", Float) = 0.5
		_ShadowOffset ("Shadow Offset", Float) = 1
		_HazeColor ("Haze Color", Color) = (1,1,1,1)
		_WaterColor1 ("Water Low", Color) = (1,1,1,1)
		_WaterColor2 ("Water High", Color) = (1,1,1,1)
		
		_Reflection ("Reflection Amount", Range (1,0)) = 0.5
		_WaveSpeed ("Wave Speed XYZ", Vector) = (1, 1, 1, 0)
		_WaveLength ("Wave Length XYZ", Vector) = (10, 10, 10, 0)
		_WaveHeight ("Wave Height XYZ", Vector) = (1, 1, 1, 0)
		
		_FoamBright ("Foam Brightness", Float) = 1
		_FoamTiling("Foam Tiling (5.0)", Float) = 5
		_FoamNormal("Foam Normals", Range (0.01,0.05)) = 0.03
		_FoamSpeed("Foam Speed", Float) = 1
		_NormalSpeed ("Ripples: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_WaterTex ("Water Texture", 2D) = "white" { }
		_Airship ("Shadow Texture", 2D) = "white" { }
		_Specular ("Specular Texture", 2D) = "white" { }
		_CubeMap ("Reflection Cubemap", CUBE) = "" {}
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Geometry"
			"LightMode" = "ForwardBase"
			"IgnoreProjector" = "True"
		}
		
		Pass {
      		Cull Back
      		Fog {Mode Off}
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			#include "AutoLight.cginc"
			
			struct vertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    float2 uv2 : TEXCOORD1;
			    float2 uv3 : TEXCOORD2;
			    float2 uv4 : TEXCOORD3;
		    	float3 cam : TEXCOORD4;
           		float3 col : TEXCOORD5;
           		float4 vtc : TEXCOORD6;
		    };
			
			// resources
			uniform sampler2D _WaterTex;
			uniform sampler2D _FoamTex;
			uniform sampler2D _Airship;
			uniform sampler2D _Specular;
			uniform samplerCUBE _CubeMap;
			
			// properties
			uniform float _ShadowSize;
			uniform float3 _WaterColor1;
			uniform float3 _WaterColor2;
			uniform float _TilesPerMeter;
			uniform float4 _WaveSpeed;
			uniform float4 _WaveLength;
			uniform float4 _WaveHeight;
			uniform float4 _NormalSpeed;
			uniform fixed _FoamBright;
			uniform float _WaveDist;
			
			uniform fixed _Reflection;
			uniform fixed _Transparency;
			uniform fixed _Fresnel;
			uniform fixed _FoamNormal;
			uniform float _FoamTiling;
			uniform fixed _FoamSpeed;
			uniform float _ShadowOffset;
			
			// global properties
			uniform fixed _OceanReflection;
			uniform fixed _TotalBrightness;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worlduv1 = worldVertex.xz * 0.25;
				float2 worlduv2 = worldVertex.xz * 0.33;
				float2 worlduv3 = (worldVertex.xz / _ShadowSize) * float2(-1,-1);
				float2 worlduv4 = (worldVertex.xz / 75) * float2(-1,-1);
			    
				// waves
				float2 timeMult = _Time.y * _WaveSpeed.xy + _WaveLength.xy * (worldVertex.zz + float2(-0.5 * worldVertex.x, 0.3 * worldVertex.x));
				float waves1 = sin(timeMult.x) * _WaveHeight.x;
				float waves2 = sin(timeMult.y) * _WaveHeight.y;
				float waveTotal = smoothstep ( -0.2, 0.666, waves1 + waves2 );
				o.col = lerp ( _WaterColor1, _WaterColor2, smoothstep ( -0.5, 0.5, waves1 + waves2));
				
				// vertex & normals
				v.vertex.y += v.color.a * (waves1 + waves2);
				
				// viewDir
				o.cam = (worldVertex - _WorldSpaceCameraPos);
			    
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worlduv1 + float2 ( _Time.xx * _NormalSpeed.xy * 0.1);
				o.uv2 = worlduv2 + float2 ( _Time.xx * _NormalSpeed.zw * 0.1);
				o.uv3 = worlduv3 + float2(0.5,0.5) - _WorldSpaceLightPos0.xz * _ShadowOffset - float2( waveTotal * 0.1, waveTotal * 0.1 );
				
				// sun glow
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				o.uv4 = mul ( worlduv4, rotMat ) + float2(0.5,0.5) - float2( waves1 * waves2 * 2, 0 );
				
				// vertex color
				o.vtc = fixed4(v.color.a, v.color.r * waveTotal * _FoamBright, v.color.a * _Reflection, v.color.a * (1 - 0.666 * waveTotal));
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
			    // normal calc
				fixed3 outcolor = i.col;
				float3 norms = tex2D(_WaterTex, i.uv1) + tex2D(_WaterTex, i.uv2);
				
			    // reflection
				fixed3 reflDir = normalize(i.cam.xyz - fixed3(norms.r,0.9,norms.g) * i.vtc.a);
				fixed3 reflection = (1 + i.vtc.x * outcolor) * texCUBE(_CubeMap, reflDir);
				outcolor = lerp ( reflection, outcolor, i.vtc.z);
				
				// shadow
				outcolor.rgb *= tex2D ( _Airship, i.uv3);
				
				// specular
				float2 specUV = i.uv4 + (norms.rg - float2( 1, 1 ) )* float2( 0.05, 0.05 );
				fixed4 spccolor = tex2D ( _Specular, specUV) * i.vtc.a * _OceanReflection;
				outcolor += spccolor.rgb;
				outcolor += spccolor.aaa;
				
				// foam
				outcolor += norms.bbb * pow(i.vtc.y,2);
				
				// combine
				return fixed4(outcolor, 1 );
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }