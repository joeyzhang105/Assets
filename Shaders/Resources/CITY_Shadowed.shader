// Copyright Mechanist Games

Shader "Mechanist CITY/Shadowed"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Angle ("Unity Shadow Flicker Override Angle", Range(0.2,0.8)) = 0.4
		_LocalSunColor ("City Sun Color", Color) = (0.8,0.6,0.4,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Geometry"
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
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "MechanistCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				fixed3 spc : TEXCOORD1;
				float shd : TEXCOORD2;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(3)
				#endif
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			// properties
			uniform float _Angle;
			uniform fixed3 _LocalSunColor;
			uniform fixed _TotalBrightness;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord0, _MainTex );
				
				// diffuse reflection
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
				o.spc = _LocalSunColor * pow ( max ( 0,  dot ( worldNormal, camDir ) ), 10 ) * 2;
				o.shd = smoothstep ( _Angle, _Angle + 0.1, max ( 0, dot ( worldNormal, normalize(_WorldSpaceLightPos0) ) ) );
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				// shadows
				#if !defined (SHADOWS_OFF)
					fixed shadow = 0.7 + 0.4 * SHADOW_ATTENUATION(i) * i.shd;
				#else
					fixed shadow = 0.7 + 0.4 * i.shd;
				#endif
				outcolor.rgb *= shadow;
				
				// specular
				outcolor.rgb += i.spc * outcolor.a * shadow;
				
				return outcolor * _TotalBrightness;
			}
			
		ENDCG
		}
	}
	FallBack "VertexLit"
}