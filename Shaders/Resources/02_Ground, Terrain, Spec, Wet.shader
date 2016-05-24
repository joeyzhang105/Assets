// Copyright Mechanist Games

Shader "Mechanist/02 - Ground, Shadow, Wet, Spec"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_Reflection("Reflection", Range (0,1)) = 0.5
		_BaseTex1 ("R Texture", 2D) = "black" {}
		_BaseTex2 ("G Texture", 2D) = "black" {}
		_BaseTex3 ("B Texture", 2D) = "black" {}
		_CubeMap ("Cubemap", CUBE) = "white" {}
		_Loc_Spc_Pow ("Specular Power (~10)", Float) = 10
		_Loc_Spc_Str ("Specular Strength, Ground (~0.1)", Float) = 0.1
		_Loc_Spc_Wat ("Specular Boost, Water (~5)", Float) = 5
		//_MixChan ("Seam Texture (r, g, b)", Vector) = (1,0,0,0)
		_WaterCut ("Water/Terrain Cut Height", Float) = 0
		_LightBase ("Water/Terrain Light Strength", Float) = 0.5
	}

	Subshader
	{
		Tags {
			"Queue" = "Geometry"
			//"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
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
			
			struct vertInput
            {
                half4 vertex : POSITION;
			  	half4 color	: COLOR;
                half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
			  	half2 texcoord1 : TEXCOORD1;
            };
			
			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half3 cam : TEXCOORD2;
				half4 vtc : TEXCOORD3;
				fixed3 spc : TEXCOORD4;
				fixed msk : TEXCOORD5;
				fixed fog : TEXCOORD6;
				
				#if !defined (SHADOWS_OFF)
   					SHADOW_COORDS(7)
   				#endif
			};
			
			// resources
			uniform sampler2D _BaseTex1;
			uniform sampler2D _BaseTex2;
			uniform sampler2D _BaseTex3;
			uniform samplerCUBE _CubeMap;
			
			// properties
			uniform half _TilesPerMeter;
			uniform half _Reflection;
			uniform fixed _WaterCut;
			uniform fixed _LightBase;
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			uniform half _Loc_Spc_Wat;
			uniform half3 _MixChan;
			
			v2f vert ( vertInput v )
			{
				v2f o;

               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				half2 worldUV = worldVertex.xz * _TilesPerMeter;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV;
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// camera direction
				#ifndef QUALITY_LOW
					o.cam = worldVertex - _WorldSpaceCameraPos;
				#else
					o.cam = half3(0,0,0);
				#endif
				
				// shadows
				#if !defined (SHADOWS_OFF)
					TRANSFER_SHADOW(o);
				#endif
				
				// vertex colors
				o.vtc = v.color;

				// lightmap height water mask
				o.msk = step ( worldVertex.y, _WaterCut );

				// specular
				#ifdef QUALITY_HGH
					float3 worldNormal = normalize ( lerp ( mul ( half4 ( v.normal,1 ), _World2Object ).xyz, float3(0,1,0), v.color.r ) );
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
			
			inline half4 inlineBaseTexture ( half2 uv, half4 vcol ) {
				half4 baseTex = tex2D ( _BaseTex1, uv ) * vcol.r;
				baseTex += tex2D ( _BaseTex2, uv ) * vcol.g;
				baseTex += tex2D ( _BaseTex3, uv ) * vcol.b;
				return baseTex;
			}
			
			half4 frag ( v2f i ) : SV_Target {
			
				half4 baseTex = inlineBaseTexture ( i.uv1, i.vtc );

				#if !defined (SHADOWS_OFF)
					half3 lightmap = inlineLightmapWithShadows ( i.uv2, SHADOW_ATTENUATION(i) );
				#else
					half3 lightmap = inlineLightmapBasic ( i.uv2 );
				#endif
				
				half3 outcolor = baseTex.rgb;
				
				#ifdef QUALITY_MED
					half3 reflectMod = half3 (baseTex.a, 0, baseTex.a);
					half3 reflection = texCUBE(_CubeMap, i.cam + reflectMod );
					half waterEdge = step ( 1, i.vtc.a + baseTex.a );
					outcolor = lerp (outcolor, reflection, waterEdge * _Reflection);
				#endif
				#ifdef QUALITY_HGH
					half3 reflectMod = half3 (baseTex.a, 0, baseTex.a);
					half3 reflection = texCUBE(_CubeMap, i.cam + reflectMod );
					half waterEdge = smoothstep ( 0.95, 1.05, i.vtc.a + baseTex.a );
					outcolor = lerp (outcolor, reflection, waterEdge * _Reflection);
				#endif
				
				#if !defined (SHADOWS_OFF)
					outcolor *= lerp(lightmap, _Gbl_Amb + _Gbl_Lgt * _LightBase * SHADOW_ATTENUATION(i), i.msk);
				#else
					outcolor *= lerp(lightmap, _Gbl_Amb + _Gbl_Lgt * _LightBase, i.msk);
				#endif
				
				#ifdef QUALITY_HGH
					outcolor *= 1 + i.spc * (1-baseTex.a + waterEdge * _Loc_Spc_Wat);
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return half4 (outcolor,1);		
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}