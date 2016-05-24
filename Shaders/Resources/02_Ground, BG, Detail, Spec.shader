// Copyright Mechanist Games

Shader "Mechanist/02 - Background, Detail, Spec"
{
	Properties
	{
		_SeamTiling ("Seam Tiling (0.25)", Float) = 0.25
		_MainTiling ("Main Tiling (3)", Float) = 3
		_MainTex ("Main Texture", 2D) = "black" {}
		_DetailTex ("Detail Texture", 2D) = "black" {}
		_SeamTex ("Seam Texture", 2D) = "black" {}
		
		_WaterCut ("Water/Terrain Cut Height", Float) = -10
		_LightBase ("Water/Terrain Light Strength", Float) = 0.5
		
		_Loc_Spc_Pow ("Specular Power (~10)", Float) = 10
		_Loc_Spc_Str ("Specular Strength (~0.5)", Float) = 0.5
	}

	Subshader
	{
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
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
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                half4 vertex : POSITION;
			  	half4 color	: COLOR;
			  	half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half2 uv3 : TEXCOORD2;
   				fixed3 lgt : TEXCOORD3;
   				fixed dtl : TEXCOORD4;
   				fixed sem : TEXCOORD5;
   				fixed3 spc : TEXCOORD6;
   				fixed fog : TEXCOORD7;
			};
			
			// properties
			uniform sampler2D _MainTex;
			uniform sampler2D _DetailTex;
			uniform sampler2D _SeamTex;
			uniform half _SeamTiling;
			uniform float4 _MainTex_ST;
			uniform float4 _DetailTex_ST;
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			uniform fixed _WaterCut;
			uniform fixed _LightBase;
			
			vertShader vert ( vertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0 * _MainTex_ST.xy;
				o.uv2 = v.texcoord0 * _DetailTex_ST.xy;
				o.uv3 = worldVertex.xz * _SeamTiling;
				
				// vertex lights
				v.color.r = lerp ( v.color.r, _LightBase, step ( worldVertex.y, _WaterCut ) ) ;
				o.lgt = inlineVLM_Full (v.color);
				
				// detail texture
				o.dtl = smoothstep( 100,10,distance (_WorldSpaceCameraPos,worldVertex));
				
				// seam texture
				o.sem = v.color.a;
				
				// specular
				#ifdef QUALITY_HGH
					float3 worldNormal = normalize ( lerp ( mul ( half4 ( v.normal,1 ), _World2Object ).xyz , float3(0,1,0), v.color.a) );
					float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
					o.spc = _Gbl_Spc * pow ( max ( 0, dot ( reflect ( -_WorldSpaceLightPos0, worldNormal), camDir ) ), _Loc_Spc_Pow ) * _Loc_Spc_Str;
				#else
					o.spc = fixed3(0,0,0);
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target
			{
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				#ifdef QUALITY_HGH
					outcolor += (tex2D ( _DetailTex, i.uv2 ) - 0.5) * i.dtl;
				#endif
				
				outcolor = lerp ( outcolor, tex2D ( _SeamTex, i.uv3 ), i.sem );
				outcolor.rgb *= i.lgt;
				
				#ifdef QUALITY_HGH
					outcolor.rgb *= 1 + i.spc * (1-outcolor.a);
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return outcolor;		
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}