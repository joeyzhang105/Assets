// Copyright Mechanist Games

Shader "Mechanist/04 - Plant, Leaves, No Bend"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (1,1,1,1)
		_BendWeight ("Character Bend Amount (0.2)", Float) = 0.2
		_MainTex ("Color Texture", 2D) = "white" {}
		
		_WindSpd ("Wind Speed (25)", Float ) = 25
		_WindAmt ("Wind Frequency", Range(0.2,1.8) ) = 1
		_WindStr ("Wind Strength", Range(0,0.2) ) = 0.1
		
		_TumbSpd ("Tumbling Speed (100)", Float ) = 200
		_TumbAmt ("Tumbling Frequency", Range(10,50) ) = 30
		_TumbStr ("Tumbling Strength", Range(0,0.2) ) = 0.1
		
		_TransparencyLM ("Lightmap Transparency", 2D ) = "white"{}
	}
	
	Subshader
	{
		LOD 100
		
		Tags {
			"Queue" = "Transparent"
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
			
			//#pragma multi_compile BEND_OFF BEND_3 BEND_6 BEND_9
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
                half4 color : COLOR;
                half2 texcoord0 : TEXCOORD0;
                half2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				half4 pos	: SV_POSITION;
				half2 uv1 : TEXCOORD0;
			 	half2 uv2 : TEXCOORD1;
				half3 lgt : TEXCOORD2;
				half3 vlm : TEXCOORD3;
	   			fixed fog : TEXCOORD4;
			};
			
			// resources
			uniform sampler2D _MainTex;
			
			// properties
			uniform float _WindSpd;
			uniform float _WindAmt;
			uniform float _WindStr;
			uniform float _TumbSpd;
			uniform float _TumbAmt;
			uniform float _TumbStr;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex );
				
				// object bending
				//float grassBend = inlinePlantSquash ( v.vertex.xyz );
				
				// wind bending
				float Coef = _WindSpd * _Time.x;
				float2 grassMove = float2 (sin(Coef + (worldVertex.x * _WindAmt)), cos(Coef + (worldVertex.z * _WindAmt))) * _WindStr;
               	
				// leaf tumbling
				Coef = _TumbSpd * _Time.x;
				float worldVertexSum = worldVertex.x + worldVertex.z;
				float tumbling = sin(Coef + _TumbAmt * worldVertexSum) * _TumbStr;
				
				// apply animations
				v.vertex.xyz += float3(grassMove.x, tumbling, grassMove.y) * v.color.a;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord0;
				o.uv2 = inlineLightmapTransform ( v.texcoord1 );
				
				// vertex lights
				half bendCol = tumbling + grassMove.x + grassMove.y;
				bendCol = bendCol * bendCol;
				//o.lgt = inlineLights ( worldVertex ) + bendCol.xxx;
				o.lgt = bendCol.xxx;
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
				fixed3 lightmap = inlineLightmapBasic ( i.uv2 );
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor.rgb *= lightmap + i.lgt;
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return outcolor;
			}
			ENDCG
		}
	}
	//fallback "VertexLit"
}