// Copyright Mechanist Games

Shader "Mechanist GUI/GUI, Loading Gradient"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {} 
		_Color0("Color, Black", Color) = (1,1,1,1)
		_Color1("Color, White", Color) = (1,1,1,1)
		//_ColorB("Color, 背景", Color) = (1,1,1,1)
		//_Alpha("Alpha Control (0,1)", Range(0, 1)) = 1
	}

	Subshader
	{
		Tags {
			"QUEUE" = "Geometry"
			"IGNOREPROJECTOR" = "true"
		}

		Pass
		{
			Cull Back
			//Blend SrcAlpha OneMinusSrcAlpha
			Lighting Off
			Fog{ Mode Off }

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11

			#include "UnityCG.cginc"

			struct vertexInput
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
			};

			struct vertShader
			{
				// basics
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
			};
			
			// resources
			uniform sampler2D _MainTex;
			
			// local properties
			uniform float3 _Color0;
			uniform float3 _Color1;

			vertShader vert(vertexInput v)
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord;
				
				return o;
			}

			fixed4 frag(vertShader i) : SV_Target{
				fixed3 outcolor = lerp (_Color0, _Color1,tex2D ( _MainTex, i.uv1 ).rgb);
//				i.vtc.rgb *= outcolor;
				return fixed4(outcolor,1);
			}

			ENDCG
		}
	}
	FallBack "VertexLit"
}