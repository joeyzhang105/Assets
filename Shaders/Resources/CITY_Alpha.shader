// Copyright Mechanist Games

Shader "Mechanist CITY/Alpha"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Angle ("Unity Shadow Flicker Override Angle", Range(0.2,0.8)) = 0.4
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Transparent-1"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		Cull Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
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
				float spc : TEXCOORD1;
				float shd : TEXCOORD2;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			// properties
			uniform float _Angle;
			
			uniform fixed _TotalBrightness;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord0, _MainTex );
				
				// diffuse reflection
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex)  + _WorldSpaceLightPos0);
				o.spc = pow ( abs ( dot ( worldNormal, camDir ) ), 30 ) * 0.5;
				o.shd = smoothstep ( _Angle, _Angle + 0.1, max ( 0, dot ( worldNormal, _WorldSpaceLightPos0 ) ) );
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				// shadows
				outcolor.rgb *= 0.5 + 0.5 * i.shd;
				
				// specular
				outcolor.rgb += i.spc;
				
				return outcolor * _TotalBrightness;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}