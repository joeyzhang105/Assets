// Copyright Mechanist Games

Shader "Mechanist CITY/Sails"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LocalSunColor ("City Sun Color", Color ) = (1, 0.7, 0.6, 0)
	}
	
	Subshader
	{
		//LOD 100
	
		Tags {
			"Queue" = "Geometry"
			//"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		Pass
		{
      		Cull Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "MechanistCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float spc : TEXCOORD1;
				float shd : TEXCOORD2;
				float vtc : TEXCOORD3;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(4)
				#endif
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			uniform fixed3 _LocalSunColor;
			
			uniform fixed _TotalBrightness;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// ripple
				float phaseOffset = 3.2 * (v.vertex.x - v.vertex.y + v.vertex.z);
				float waveU = sin ( -v.texcoord.x * 5 + phaseOffset + _Time.w * 1.8 );
				float waveV = sin ( v.texcoord.y * 15 + phaseOffset + _Time.w * 1.8 );
				float waves = (waveU + waveV) * v.color.a;
				v.vertex.xyz += waves * v.normal * 0.013;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord, _MainTex );
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				// diffuse reflection
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
				o.spc = pow ( abs ( dot ( worldNormal, camDir ) ), 15 ) + waves * 0.25;
				o.shd = (1.1 - v.color.a);
				o.vtc = 0.4 * v.color.a;
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				// shadows
				#if !defined (SHADOWS_OFF)
					fixed shadow = 0.5 + 0.5 * SHADOW_ATTENUATION(i) * i.shd;
				#else
					fixed shadow = 0.5 + 0.5 * i.shd;
				#endif
				outcolor.rgb *= shadow + i.vtc;
				
				// specular
				outcolor.rgb += i.spc * outcolor.a * shadow * _LocalSunColor * 2;
				
				return outcolor * _TotalBrightness;
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}