// Copyright Mechanist Games

Shader "Mechanist/02 - Ground, Background"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_BaseTex ("R Texture", 2D) = "black" {}
	}

	Subshader
	{
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
			
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                half4 vertex : POSITION;
			  	half4 color	: COLOR;
                half2 texcoord0 : TEXCOORD0;
                half2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
   				fixed3 lgt : TEXCOORD2;
	   			fixed fog : TEXCOORD3;
			};
			
			// properties
			uniform sampler2D _BaseTex;
			uniform half _TilesPerMeter;
			
			vertShader vert ( vertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				half2 worldUV = worldVertex.xz * _TilesPerMeter;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV;
   				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// vertex lights
				o.lgt = inlineVLM_Full (v.color);
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
				fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				fixed3 outcolor = tex2D ( _BaseTex, i.uv1 );
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