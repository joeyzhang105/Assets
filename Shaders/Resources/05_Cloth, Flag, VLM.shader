// Copyright Mechanist Games

Shader "Mechanist/05 - Cloth, Flag, VLM"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) = "white" {}
		
		_WindSpd ("Wind Speed (25)", Float ) = 25
		_WindAmt ("Wind Amount", Range ( 0.5, 1.5 ) ) = 1
		_WindStr ("Wind Distance", Range ( 0.0, 0.4 ) ) = 0.2
		
		_RippSpd ("Ripple Speed", Float ) = 100
		_RippAmt ("Ripple Amount", Range ( 2, 6 ) ) = 4
		_RippStr ("Ripple Distance", Range ( 0.0, 0.1 ) ) = 0.05
		
		_ClothVector ("Cloth Vector", Vector) = (1,1,0.1,1)
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
      		Lighting Off
      		Fog {Mode Off}
									
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			//#pragma multi_compile LIGHTS_OFF LIGHTS_4 LIGHTS_8 LIGHTS_12
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
						
			struct VertInput
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half4 color : COLOR;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				fixed shn : TEXCOORD2;
				fixed3 lgt : TEXCOORD3;
	   			fixed fog : TEXCOORD4;
			};
			
			// resources
			uniform sampler2D _MainTex;
			
			// properties
			uniform float _WindSpd;
			uniform float _WindAmt;
			uniform float _WindStr;
			uniform float _RippSpd;
			uniform float _RippAmt;
			uniform float _RippStr;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				// wind
				float Coef = _WindSpd * _Time.x + worldVertex.y * _WindAmt;
				float2 clothWind = float2 (sin(Coef), cos(Coef)) * v.color.a * _WindStr;
               	
				// rippling
				Coef = _RippSpd * _Time.x + worldVertex.y * _RippAmt;
				float2 clothRipp = float2 (sin(Coef), cos(Coef)) * v.color.a * _RippStr;
				
				// apply animations
				float2 clothMove = clothWind + clothRipp;
				float3 clothTotal = float3(clothMove.x, 0, clothMove.y);
				v.vertex.xyz += clothTotal;
				
				// normals to frag
				o.shn = smoothstep( -0.05,0.05, clothRipp.x + clothRipp.y ) * 1.5 - 0.5;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				
				// vertex lights
				o.lgt = inlineVLM_Full ( v.color);
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
							
			fixed4 frag ( vertShader i) : SV_Target {
			
				fixed4 baseTex = tex2D ( _MainTex, i.uv1 );
								
				fixed3 outcolor = baseTex.rgb;
				outcolor *= i.lgt;
				outcolor *= 1 + i.shn * baseTex.a;
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return fixed4(outcolor.rgb,1);
			}
		ENDCG
		}
	}
	//fallback "VertexLit"
}