// Copyright Mechanist Games

Shader "Mechanist/04 - Plants, Tree"
{
	Properties
	{
		_MainTex ("Tree Painted Texture", 2D) = "white" {}
		_BarkTex ("Bark Tiling Texture", 2D) = "white" {}
		_Loc_Spc_Pow ("Specular Power (~10)", Float) = 10
		_Loc_Spc_Str ("Specular Strength (~0.5)", Float) = 0.5
	}

	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Geometry"
			//"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
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
				fixed3 spc : TEXCOORD3;
	   			fixed fog : TEXCOORD4;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _BarkTex;
			uniform half4 _BarkTex_ST;
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			
			Varys vert ( VertInput v )
			{
				Varys o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
   				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				o.uv3 = TRANSFORM_TEX ( v.texcoord0, _BarkTex );
				
				// specular
				#ifdef QUALITY_HGH
               		float3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
					float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
					o.spc = _Gbl_Spc * pow ( max ( 0, dot ( worldNormal, camDir ) ), _Loc_Spc_Pow ) * _Loc_Spc_Str;
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
							
			fixed4 frag ( Varys i) : SV_Target {
			
				fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				
				fixed3 basetex = tex2D ( _MainTex, i.uv1 );
				fixed3 detail = tex2D ( _BarkTex, i.uv3 );
				fixed3 outcolor = basetex * lightmap * detail;
				
				#ifdef QUALITY_HGH
					outcolor *= 1 + lightmap * detail * i.spc;
				#endif
				
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