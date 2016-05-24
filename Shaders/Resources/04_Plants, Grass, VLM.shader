// Copyright Mechanist Games

Shader "Mechanist/04 - Plant, Grass, VLM"  
{
	Properties
	{
		_WindSpd ("Wind Speed (50)", Float ) = 50
		_WindAmt ("Wind Frequency", Range(0.2,2.2) ) = 1.2
		_WindStr ("Wind Strength", Range(0,0.3) ) = 0.15
		_MainTex ("Color Texture", 2D) = "white" {}
		_ShimmerStr ("Shimmer Strength (~0.2)", Float) = 0.15
		//_TintColor ("Tint Color
	}
	
	Subshader
	{
		LOD 100
		
		Tags {
			"Queue" = "Transparent-1"
			//"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		Cull Off
      		Lighting Off
      		Fog {Mode Off}
									
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile BEND_OFF BEND_3 BEND_6 BEND_9
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
						
			struct VertInput
            {
                half4 vertex : POSITION;
                half4 color : COLOR;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half4 com : TEXCOORD2;
	   			fixed fog : TEXCOORD3;
			};
			
			// resources
			uniform sampler2D _MainTex;
			
			// properties
			uniform float _DetailDistance;
			uniform float _WindSpd;
			uniform float _WindAmt;
			uniform float _WindStr;
			uniform float _ShimmerStr;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
               	
				// object bending
				float2 grassBend = inlineGrassBend ( worldVertex );
				
				// wind bending
				#ifdef QUALITY_HGH
					float Coef = _WindSpd * _Time.x + (worldVertex.x + worldVertex.z) * _WindAmt;
					float grassWindX = sin(Coef);
					float grassWindZ = cos(Coef);
					float2 grassWind = float2 (grassWindX,grassWindZ) * _WindStr;
				#else
					float2 grassWind = float2(0,0);
				#endif
				
				// apply animations
				v.vertex.xz += (grassBend + grassWind) * v.color.a;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				
				// vertex lights, vertex lightmap, bend highlight, distance fade
				half3 lgt = inlineVLM_Full ( v.color );
				half bnd = 3 * (grassBend.x * grassBend.x + grassBend.y * grassBend.y);
				
				#ifdef QUALITY_HGH
					half wnd = (1 + 0.5 * grassWindX) * sin(_Time.z + 0.333 * (worldVertex.x + worldVertex.z)) * v.color.a;
					wnd += (1 + 0.5 * grassWindZ) * sin(_Time.z + 0.3 * (worldVertex.x - worldVertex.z)) * v.color.a;
					wnd *= _ShimmerStr;
					wnd = max ( 0, wnd );
				#else
					half wnd = 0;
				#endif
					
				// fade
				half fade = 1 - clamp ( (distance(_WorldSpaceCameraPos,worldVertex) - _DetailDistance) * 0.1,0,1);
				
				// composite lighting
				o.com = half4( lgt + wnd.xxx + bnd.xxx, fade );
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i) : SV_Target {
			
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 ) * i.com;
				
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