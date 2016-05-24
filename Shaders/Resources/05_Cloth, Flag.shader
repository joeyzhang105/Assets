// Copyright Mechanist Games

Shader "Mechanist/05 - Cloth, Flag"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) = "white" {}
		
		_WindSpd ("Wind Speed (25)", Float ) = 25
		_WindAmt ("Wind Amount (1)", Float ) = 1
		_WindStr ("Wind Distance (0.2)", Float ) = 0.2
		_Side ("Sideways Offset", Range(0,2) ) = 1
		
		_RippSpd ("Ripple Speed", Float ) = 100
		_RippAmt ("Ripple Amount (4.0)", Float ) = 4
		_RippStr ("Ripple Distance (0.1)", Float ) = 0.1
		_RippBrt ("Ripple Brightness", Range (0.2,2)) = 1
		
		_ClothVector ("Cloth Vector", Vector) = (1,1,1,1)
		
		_TransparencyLM ("Lightmap Transparency", 2D ) = "black"{}
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
			
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
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
			  	half2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				fixed shn : TEXCOORD2;
	   			fixed fog : TEXCOORD3;
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
			uniform float _RippBrt;
			uniform float _Side;
			uniform float3 _ClothVector;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				// wind
				float Coef = _WindSpd * _Time.x + worldVertex.y * _WindAmt + (worldVertex.x + worldVertex.z) * _Side;
				float2 clothWind = float2 (sin(Coef), cos(Coef)) * v.color.a * _WindStr;
               	
				// rippling
				Coef = _RippSpd * _Time.x + worldVertex.y * _RippAmt - (worldVertex.x + worldVertex.z) * _Side;
				float2 clothRipp = float2 (sin(Coef), cos(Coef)) * v.color.a * _RippStr;
				
				// apply animations
				float2 clothMove = clothWind + clothRipp;
				float3 clothTotal = float3(clothMove.x, clothMove.x, clothMove.y) * _ClothVector;
				v.vertex.xyz += clothTotal;
				
				// ripple shine
				o.shn = _RippBrt * smoothstep( -0.2,0.2, clothRipp.x + clothRipp.y );
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
							
			fixed4 frag ( vertShader i) : SV_Target {
			
				fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				fixed4 baseTex = tex2D ( _MainTex, i.uv1 );
								
				fixed3 outcolor = baseTex.rgb;
				outcolor *= lightmap;
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