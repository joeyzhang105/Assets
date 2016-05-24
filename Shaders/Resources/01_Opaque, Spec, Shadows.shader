// Upgrade NOTE: replaced 'defined SHADOWS_OFF' with 'defined (SHADOWS_OFF)'

// Copyright Mechanist Games

Shader "Mechanist/01 - Opaque, Spec, Shadows"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			
			#pragma multi_compile_fwdbase
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
			struct VertInput
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
			 	half2 texcoord1 : TEXCOORD1;
            };
			
			struct Varys
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			 	half2 uv2 : TEXCOORD1;
	   			fixed3 spc : TEXCOORD2;
	   			fixed fog : TEXCOORD3;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(4)
				#endif
			};
			
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			Varys vert ( VertInput v )
			{
				Varys o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord0, _MainTex );
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// specular
				#ifdef QUALITY_HGH
               		float3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
					float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
					o.spc = _Gbl_Spc * pow ( max ( 0, dot ( worldNormal, camDir ) ), _Loc_Spc_Pow ) * _Loc_Spc_Str;
				#endif
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			fixed4 frag ( Varys i ) : SV_Target {
			
				#if !defined (SHADOWS_OFF)
					fixed3 lightmap = inlineLightmapWithShadows ( i.uv2, SHADOW_ATTENUATION(i) );
				#else
					fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				#endif
				
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
	FallBack "Diffuse"
}