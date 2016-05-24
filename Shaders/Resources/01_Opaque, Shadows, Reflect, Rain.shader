// Upgrade NOTE: replaced 'defined SHADOWS_OFF' with 'defined (SHADOWS_OFF)'

// Copyright Mechanist Games

Shader "Mechanist/01 - Opaque, Shadows, Reflective, Rain"
{
	Properties
	{
		_MainTex ("Rain Texture", 2D) = "white" {}
		_Reflection("Reflection", Range (0,1)) = 0.5
		_Wobble ("Reflect Wobble", Range (0,1)) = 0.5
		_LightMod("Light Modification", Range (-0.5,0.5)) = 0
		_BaseTex ("Color Texture", 2D) = "white" {}
		_CubeMap ("Cube Map", CUBE) = "black" {}
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
                half2 texcoord0 : TEXCOORD0;
			  	half2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half2 uv3 : TEXCOORD2;
				half3 cam : TEXCOORD3;
	   			fixed fog : TEXCOORD4;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(5)
				#endif
			};
			
			uniform sampler2D _BaseTex;
			uniform half4 _BaseTex_ST;
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform samplerCUBE _CubeMap;
			uniform half _Reflection;
			uniform half _Wobble;
			uniform half _LightMod;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
       			
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX (v.texcoord0, _MainTex);
				o.uv2 = TRANSFORM_TEX (v.texcoord0, _BaseTex);
				o.uv3 = inlineLightmapTransform ( v.texcoord1 );
				
				// reflection
            	o.cam = (worldVertex - _WorldSpaceCameraPos);
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
																																	
				return o;
			}
			
			fixed4 frag ( vertShader i) : SV_Target {
			
				#if !defined (SHADOWS_OFF)
					fixed3 lightmap = inlineLightmapWithShadows ( i.uv3, SHADOW_ATTENUATION(i) );
				#else
					fixed3 lightmap = inlineLightmapBasic ( i.uv3 );
				#endif
				
				fixed3 raintex = tex2D ( _MainTex, i.uv1 );
				fixed4 outcolor = tex2D ( _BaseTex, i.uv2 + raintex.rb );
				fixed3 refcolor = texCUBE( _CubeMap, i.cam + raintex);
				outcolor.rgb = lerp ( outcolor.rgb, refcolor, _Reflection - outcolor.a );
				outcolor.rgb *= _LightMod + lightmap;
				outcolor += raintex.r;
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return fixed4 (outcolor.rgb,1);
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}