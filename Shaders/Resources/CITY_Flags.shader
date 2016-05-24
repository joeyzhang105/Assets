// Copyright Mechanist Games

Shader "Mechanist CITY/Flags"
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
			"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
		}
		
		Pass
		{
      		Cull Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
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
				fixed3 spc : TEXCOORD1;
				fixed shd : TEXCOORD2;
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
				
				// ripple
				float phaseOffset = 2 * (v.vertex.y + v.vertex.z);
				float waves = sin ( ( phaseOffset + v.texcoord.x + 0.5 * v.texcoord.y ) * 15 + phaseOffset + _Time.w * 2 );
				v.vertex.xyz += waves * v.normal * 0.004 * v.color.r;
				
				// wind
				v.vertex.z -= (0.333 - sin (v.vertex.z * 30 + v.vertex.y * 60 + _Time.w * 0.666)) * 0.007 * v.color.a;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord, _MainTex );
				
				// diffuse reflection
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
				o.spc = _LocalSunColor * (pow ( abs ( dot ( worldNormal, camDir ) ), 15 ) * 3 + waves * 0.5);
				o.shd = max ( 0, dot ( worldNormal, _WorldSpaceLightPos0 ) );
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				//shadow
				fixed shadow = 0.7 + 0.4 * i.shd;
				outcolor.rgb *= shadow;
				
				// specular
				outcolor.rgb += i.spc * outcolor.a;
				
				return outcolor * _TotalBrightness;
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}