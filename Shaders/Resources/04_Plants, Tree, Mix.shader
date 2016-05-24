// Copyright Mechanist Games

Shader "Mechanist/04 - Plants, Tree, Mix"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_MainTex ("Tree Painted Texture", 2D) = "white" {}
		_BaseTex ("Ground Mix (A)", 2D) = "white" {}
		_BarkTex ("Bark Tiling Texture", 2D) = "white" {}
		_Loc_Spc_Pow ("Specular Power (~10)", Float) = 10
		_Loc_Spc_Str ("Specular Strength, Ground (~0.1)", Float) = 0.1
		_Loc_Spc_Wat ("Specular Boost, Water (~5)", Float) = 5
		
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
			  	half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
                half2 texcoord1 : TEXCOORD1;
            };
			
			struct Varys
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			 	half2 uv2 : TEXCOORD1;
			 	half2 uv3 : TEXCOORD2;
			 	half2 uv4 : TEXCOORD3;
			 	half2 vtc : TEXCOORD4;
				fixed3 spc : TEXCOORD5;
	   			fixed fog : TEXCOORD6;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _BaseTex;
			uniform sampler2D _BarkTex;
			
			// properties
			uniform half _TilesPerMeter;
			uniform half4 _BarkTex_ST;
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			uniform half _Loc_Spc_Wat;
			
			Varys vert ( VertInput v )
			{
				Varys o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				half2 worldUV = worldVertex.xz * _TilesPerMeter;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				o.uv2 = TRANSFORM_TEX ( v.texcoord1, _BarkTex );
				o.uv3 = worldUV;
				o.uv4 = inlineLightmapTransform ( v.texcoord1 );
				
				// vertex colors
				o.vtc = half2(v.color.a, 1-v.color.a);
				
				// specular
				v.normal = lerp ( v.normal, float3(0,1,0), 1 - v.color.a);
               	float3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
				o.spc = 1 + _Gbl_Spc * pow ( max ( 0, dot ( reflect ( -_WorldSpaceLightPos0, worldNormal), camDir ) ), _Loc_Spc_Pow ) * _Loc_Spc_Str;
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
							
			fixed4 frag ( Varys i) : SV_Target {
				
				fixed4 texcolor = tex2D ( _MainTex, i.uv1 );
				
				fixed3 outcolor = texcolor.rgb *  tex2D ( _BarkTex, i.uv2 ) * i.spc * i.vtc.r;
				outcolor += tex2D ( _BaseTex, i.uv3 ) * i.vtc.g;
				
				fixed3 lightmap = inlineLightmapBasic ( i.uv4 );
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