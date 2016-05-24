// Copyright Mechanist Games

Shader "Mechanist/01 - Opaque"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Geometry"
			//"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
      		Cull Back
      		Fog {Mode Off}
      		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct VertInput
            {
                half4 vertex : POSITION;
                half2 texcoord0 : TEXCOORD0;
			 	half2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			 	half2 uv2 : TEXCOORD1;
	   			fixed fog : TEXCOORD2;
			};
			
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor *= lightmap;
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return fixed4 (outcolor,1);	
			}
			
			ENDCG
		}
	}
	//FallBack "Diffuse"
}