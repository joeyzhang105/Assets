// Copyright Mechanist Games

Shader "Mechanist/02 - Ground, Shadow, Mix"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_BaseTex1 ("Mesh UV Texture", 2D) = "black" {}
		_BaseTex2 ("World UV Texture", 2D) = "black" {}
		_Loc_Spc_Pow ("Specular Power (~10)", Float) = 10
		_Loc_Spc_Str ("Specular Strength, Ground (~0.1)", Float) = 0.1
		_Loc_Spc_Wat ("Specular Boost, Water (~5)", Float) = 5
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
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half2 uv3 : TEXCOORD2;
				half4 vtc : TEXCOORD3;
				fixed3 spc : TEXCOORD4;
	   			fixed fog : TEXCOORD5;
   				
				#if !defined (SHADOWS_OFF)
			   	    SHADOW_COORDS(6)
				#endif
			};
			
			// resources
			uniform sampler2D _BaseTex1;
			uniform sampler2D _BaseTex2;
			
			// properties
			uniform half _TilesPerMeter;
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			uniform half _Loc_Spc_Wat;
			
			vertShader vert ( vertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				half2 worldUV = worldVertex.xz * _TilesPerMeter;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV;
				o.uv2 = v.texcoord0;
				o.uv3 = inlineLightmapTransform ( v.texcoord1 );
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				// vertex colors
				o.vtc = v.color;
				
				// specular
				float3 worldNormal = normalize ( mul ( half4 ( v.normal,0 ), _World2Object ).xyz);
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
				o.spc = _Gbl_Spc * pow ( max ( 0, dot ( reflect ( -_WorldSpaceLightPos0, worldNormal), camDir ) ), _Loc_Spc_Pow ) * _Loc_Spc_Str;
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			half4 frag ( vertShader i ) : SV_Target {
			
				half4 baseTex = tex2D ( _BaseTex1, i.uv2 );
				half4 splatTex = tex2D ( _BaseTex2, i.uv1 );
				
				#if !defined (SHADOWS_OFF)
					half3 lightmap = inlineLightmapWithShadows ( i.uv3, SHADOW_ATTENUATION(i) );
				#else
					half3 lightmap = inlineLightmapBasic ( i.uv3 );
				#endif
				
				half4 outcolor = lerp ( splatTex, baseTex, i.vtc.r );
				outcolor.rgb *= lightmap;
				outcolor.rgb *= 1 + i.spc * (1-outcolor.a);
				
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