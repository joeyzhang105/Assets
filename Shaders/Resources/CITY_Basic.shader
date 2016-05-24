// Copyright Mechanist Games

Shader "Mechanist CITY/Basic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LocalSunColor ("City Sun Color", Color ) = (1, 0.7, 0.6, 0)
	}
	
	Subshader
	{
		LOD 100
	
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
				float3 spc : TEXCOORD1;
				float shd : TEXCOORD2;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			// properties
			uniform fixed3 _LocalSunColor;
			uniform fixed _TotalBrightness;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				
				// spec reflection
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
				o.spc =  _LocalSunColor * pow ( max ( 0, dot ( worldNormal, camDir ) ), 10 ) * 2;
				o.shd = max ( 0, dot ( worldNormal, normalize(_WorldSpaceLightPos0) ) );
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				// shadows
				fixed shadow = 0.7 + 0.4 * i.shd;
				outcolor.rgb *= shadow;
				
				// specular
				outcolor.rgb += i.spc * outcolor.a * shadow;
				
				return outcolor * _TotalBrightness;
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}