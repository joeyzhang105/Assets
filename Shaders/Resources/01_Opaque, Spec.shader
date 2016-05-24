// Copyright Mechanist Games

Shader "Mechanist/01 - Opaque, Spec"
{
	Properties
	{
		_MainTex ("RGB Texture, A Specular", 2D) = "white" {}
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
                half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
			 	half2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			 	half2 uv2 : TEXCOORD1;
	   			fixed3 spc : TEXCOORD2;
	   			fixed fog : TEXCOORD3;
			};
			
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
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
			
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor.rgb *= lightmap;
				
				#ifdef QUALITY_HGH
					outcolor.rgb *= 1 + i.spc * outcolor.a;
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
	//FallBack "Diffuse"
}