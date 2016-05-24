// Copyright Mechanist Games

Shader "Mechanist/02 - Ground, Shadow, Wet"
{
	Properties
	{
		_TilesPerMeter ("Tiles Per Meter (0.25)", Float) = 0.25
		_Reflection("Reflection", Range (0,1)) = 0.5
		_BaseTex1 ("R Texture", 2D) = "black" {}
		_BaseTex2 ("G Texture", 2D) = "black" {}
		_BaseTex3 ("B Texture", 2D) = "black" {}
		_CubeMap ("Cubemap", CUBE) = "white" {}
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
			//#pragma multi_compile LIGHTS_OFF LIGHTS_4 LIGHTS_8 LIGHTS_12
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			#include "AutoLight.cginc"
			
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
				half3 cam : TEXCOORD2;
				half4 vtc : TEXCOORD3;
	   			fixed fog : TEXCOORD4;
   				
				#if !defined (SHADOWS_OFF)
			   	    SHADOW_COORDS(5)
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
			
			vertShader vert ( vertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				half2 worldUV = worldVertex.xz * _TilesPerMeter;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV;
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// camera direction
				o.cam = worldVertex - _WorldSpaceCameraPos;
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				// vertex colors
				o.vtc = v.color;
				
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
			
			half4 frag ( vertShader i ) : SV_Target {
			
				half4 baseTex = inlineBaseTexture ( i.uv1, i.vtc );
				
				#if !defined (SHADOWS_OFF)
					half3 lightmap = inlineLightmapWithShadows ( i.uv2, SHADOW_ATTENUATION(i) );
				#else
					half3 lightmap = inlineLightmapBasic ( i.uv2 );
				#endif
				
				half3 reflectMod = half3 (baseTex.a, 0, baseTex.a);
				half3 reflection = texCUBE(_CubeMap, i.cam + reflectMod );
				half waterEdge = step ( 1, i.vtc.a + baseTex.a );
				
				half3 outcolor = baseTex.rgb;
				outcolor = lerp (outcolor, reflection, waterEdge * _Reflection);
				outcolor *= lightmap;
				
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