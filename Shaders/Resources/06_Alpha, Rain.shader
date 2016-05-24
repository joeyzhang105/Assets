// Copyright Mechanist Games

Shader "Mechanist/07 - Alpha, Rain"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Transparency ("Rain Transparency", Float ) = 10
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Transparent-2"
			//"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha One
      		Cull Off
      		Lighting Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			//#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
	   			fixed fog : TEXCOORD1;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Transparency;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				
				// fog
				#ifdef QUALITY_HGH
					float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
					o.fog = max ( 0, v.color.a - inlineFogVert ( worldVertex.xyz ) );
				#endif
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				outcolor = (outcolor.r + outcolor.g * 3 + outcolor.b) * _Transparency;
				
				// fog
				outcolor.a *= i.fog;
				
				return outcolor;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}