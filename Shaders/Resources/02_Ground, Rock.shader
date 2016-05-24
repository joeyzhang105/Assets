// Copyright Mechanist Games

Shader "Mechanist/02 - Ground, Rock, Shadows"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_BaseTex ("Terrain Texture", 2D) = "white" {}
		_MainTex ("Rock Texture", 2D) = "white" {}
		_RockColor ("Rock Color", Color) = (1,1,1,1)
		
		_TransparencyLM ("Lightmap Transparency", 2D ) = "white"{}
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
			#pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF
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
                half2 texcoord1 : TEXCOORD1;
            };
			
			struct Varys
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			 	half2 uv2 : TEXCOORD1;
				half2 uv3 : TEXCOORD2;
				fixed2 vtc : TEXCOORD3;
	   			fixed fog : TEXCOORD4;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _BaseTex;
			
			// properties
			uniform half _TilesPerMeter;
			uniform fixed3 _RockColor;
			
			Varys vert ( VertInput v )
			{
				Varys o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				half2 worldUV = worldVertex.xz * _TilesPerMeter;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
   				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				o.uv3 = worldUV;
				
				o.vtc = half2 ( 1 - v.color.a, v.color.a );
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
							
			fixed4 frag ( Varys i) : SV_Target {
			
				fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 ) * i.vtc.x * _RockColor;
				outcolor += tex2D ( _BaseTex, i.uv3 ) * i.vtc.y;
				outcolor *= lightmap;
				
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