// Copyright Mechanist Games

Shader "Mechanist CHAR/Character, Enemy C"
{
	Properties
	{
		_TintColor ("Tint Color", Vector) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_ChanTex ("Spec Texture", 2D) = "white" {}
		_CubeMap ("Cubemap", CUBE) = "white" {}
  		
  		[HideInInspector] _Hit ( "Hidden Hit", Float ) = 0
  		[HideInInspector] _BaTi ( "Hidden BaTi", Float ) = 0
	}

	Subshader
	{
		
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
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
			struct vertexInput
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
                half2 texcoord	: TEXCOORD0;
            };
			
			struct vertShader
			{
				// basics
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				
				// frag lighting
				#ifdef QUALITY_HGH
			    	half3 spc : TEXCOORD2;
			    	half3 rim : TEXCOORD3;
			    	half shd : TEXCOORD4;
					half3 lgt : TEXCOORD5;
					half3 ref : TEXCOORD6;
				#endif
				#ifdef QUALITY_MED
			    	half3 spc : TEXCOORD2;
			    	half3 rim : TEXCOORD3;
			    	half shd : TEXCOORD4;
					half3 lgt : TEXCOORD5;
				#endif
				#ifdef QUALITY_LOW
			    	half3 spc : TEXCOORD2;
			    	half3 rim : TEXCOORD3;
			    	half shd : TEXCOORD4;
					half3 lgt : TEXCOORD5;
				#endif
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(7)
				#endif
			
			};
				// assets
				uniform sampler2D _MainTex;
				uniform sampler2D _ChanTex;
				uniform samplerCUBE _CubeMap;
				
				// properties
				uniform half _Hit;
				uniform half _BaTi;
				uniform fixed3 _TintColor;
				
			vertShader vert ( vertexInput v )
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord;
				
				// frag lighting
				#ifdef QUALITY_HGH
               		half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
               		half3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
					half3 lightDirect = normalize(_WorldSpaceLightPos0.xyz);
					half dotprod = max ( 0, dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ) );
					o.spc = pow ( dotprod, 10 ) * _Gbl_Spc;
	            	o.rim = pow ( 1 - dotprod, 2 ) * _Gbl_Rim;
            		o.shd = max ( 0, dot ( worldNormal, lightDirect ) );
            		o.ref = reflect ( normalize ( worldVertex - _WorldSpaceCameraPos ), worldNormal );
				#endif
				#ifdef QUALITY_MED
               		half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
               		half3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
					half3 lightDirect = normalize(_WorldSpaceLightPos0.xyz);
					half dotprod = max ( 0, dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ) );
					o.spc = pow ( dotprod, 10 ) * _Gbl_Spc;
	            	o.rim = pow ( 1 - dotprod, 2 ) * _Gbl_Rim;
            		o.shd = max ( 0, dot ( worldNormal, lightDirect ) );
				#endif
				#ifdef QUALITY_LOW
					half3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
					half3 lightDirect = normalize(_WorldSpaceLightPos0.xyz);
					half dotprod = max ( 0, dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ) );
					o.spc = pow ( dotprod, 10 ) * _Gbl_Spc * 0.5;
	            	o.rim = pow ( 1 - dotprod, 2 ) * _Gbl_Rim;
            		o.shd = max ( 0, dot ( worldNormal, lightDirect ) );
				#endif
					
				// hit effect
				half hit = max ( 0, _Hit * pow ( 1.0 - max ( 0, dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ) ), 4 ) ); // hit effect
				half3 bati = _BaTi * half3(1,0,0) * sin ( _Time.z * 3 );
				
				// vertex lighting
				//o.lgt = inlineLights ( worldVertex ) + hit + bati * bati;
				o.lgt = hit + bati * bati;
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
				// textures
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 ).grb;
				
				// channels
				#ifndef QUALITY_LOW
					fixed3 channels = tex2D ( _ChanTex, i.uv1 );
				#endif
				
				// phong shadows
				#ifdef QUALITY_HGH
					fixed shdlight = smoothstep ( 0.2, 0.3, i.shd * channels.b );
				#endif
				#ifdef QUALITY_MED
					fixed shdlight = smoothstep ( 0.2, 0.3, i.shd * channels.b );
				#endif
				#ifdef QUALITY_LOW
					fixed shdlight = step ( 0.25, i.shd );
				#endif
				
				// realtime shadows
				#if !defined (SHADOWS_OFF)
					shdlight *= SHADOW_ATTENUATION(i);
				#endif
				
				// spec, rim
				#ifdef QUALITY_HGH
					fixed3 spclight = i.spc * channels.r;
					fixed3 rimlight = i.rim * channels.b;
				#endif
				#ifdef QUALITY_MED
					fixed3 spclight = i.spc * channels.r;
					fixed3 rimlight = i.rim * channels.b;
				#endif
				#ifdef QUALITY_LOW
					fixed3 spclight = i.spc;
					fixed3 rimlight = i.rim;
				#endif
				
				// reflection
				#ifdef QUALITY_HGH
					fixed3 reflight = texCUBE( _CubeMap, i.ref );
					reflight *= 0.5 + outcolor;
					outcolor = lerp ( outcolor, reflight, channels.g);
				#endif
				
				// composite
				#ifdef QUALITY_HGH
					outcolor *= 0.2 + _Gbl_Amb + _Gbl_Lgt * shdlight;
					outcolor *= 0.6 + spclight + rimlight + i.lgt;
				#endif
				#ifdef QUALITY_MED
					outcolor *= 0.2 + _Gbl_Amb + _Gbl_Lgt * shdlight;
					outcolor *= 0.5 + spclight + rimlight + i.lgt;
				#endif
				#ifdef QUALITY_LOW
					outcolor *= 0.2 + _Gbl_Amb + _Gbl_Lgt * shdlight;
					outcolor *= 0.4 + spclight + rimlight + i.lgt;
				#endif

				outcolor *= _TintColor;
				
				return fixed4 (outcolor.rgb,1);
			}
				
			ENDCG
		}
	}
	FallBack "Diffuse"
}