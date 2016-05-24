// Copyright Mechanist Games

Shader "Mechanist/01 - Opaque, VLM"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) = "white" {}
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
			
			//#pragma multi_compile LIGHTS_OFF LIGHTS_4 LIGHTS_8 LIGHTS_12
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct VertInput
            {
                half4 vertex : POSITION;
                half4 color : COLOR;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct Varys
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				fixed3 vlm : TEXCOORD1;
	   			fixed fog : TEXCOORD2;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _BarkTex;
			uniform half4 _BarkTex_ST;
			
			Varys vert ( VertInput v )
			{
				Varys o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
								
				// vertex lights
				//o.lgt = inlineLights ( worldVertex ) + inlineVLM_Full ( v.color );
				o.vlm = inlineVLM_Full ( v.color );
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
							
			fixed4 frag ( Varys i) : SV_Target {
				
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor *= i.vlm;
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return fixed4 (outcolor.rgb,1);
			}
			
			ENDCG
		}
	}
	//FallBack "VertexLit"
}