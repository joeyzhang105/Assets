// Upgrade NOTE: replaced 'defined SHADOWS_OFF' with 'defined (SHADOWS_OFF)'

// Copyright Mechanist Games

Shader "Mechanist/01 - Opaque, Shadows, Reflective"
{
	Properties
	{
		_Reflection("Reflection", Range (0,1)) = 0.5
		_Wobble("Reflect Wobble", Range (0,1)) = 0.5
		_MainTex ("Texture", 2D) = "white" {}
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
			//#pragma multi_compile LIGHTS_OFF LIGHTS_4 LIGHTS_8 LIGHTS_12
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
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
				half3 cam : TEXCOORD2;
	   			fixed fog : TEXCOORD3;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(4)
				#endif
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
			};
			
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
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// reflection
            	o.cam = (worldVertex - _WorldSpaceCameraPos);
				
				// vertex lights
				//o.lgt = inlineLights ( worldVertex );
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
																																		
				return o;
			}
			
			fixed4 frag ( vertShader i) : SV_Target {
			
				#if !defined (SHADOWS_OFF)
					fixed3 lightmap = inlineLightmapWithShadows ( i.uv2, SHADOW_ATTENUATION(i) );
				#else
					fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				#endif
				
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				half3 reflectMod = i.cam.xyz + outcolor.rgb * half3(2,2,2);
				outcolor.rgb = lerp ( outcolor.rgb, texCUBE( _CubeMap, reflectMod), _Reflection - outcolor.a );
				outcolor.rgb *= lightmap;
				
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