// Upgrade NOTE: replaced 'defined SHADOWS_OFF' with 'defined (SHADOWS_OFF)'

// Copyright Mechanist Games

Shader "Mechanist GUI/Ground, Shadows, Fade"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScrollUV ("SCroll UV", Vector) = (0,0,0,0)
	}

	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Geometry"
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
			
			struct Varys
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			 	half2 uv2 : TEXCOORD1;
	   			//fixed3 lgt : TEXCOORD2;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(3)
				#endif
			};
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _ScrollUV;
			
			Varys vert ( VertInput v )
			{
				Varys o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord0, _MainTex );
				o.uv1 += _Time.yy * _ScrollUV.xy;
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// vertex lights
				//o.lgt = inlineLights ( worldVertex );
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				return o;
			}
			
			fixed4 frag ( Varys i ) : SV_Target {
				
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 );
				#if !defined (SHADOWS_OFF)
					outcolor *= 0.5 + 0.5 * SHADOW_ATTENUATION(i);
				#endif
				return fixed4 (outcolor,1);	
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}