// Copyright Mechanist Games

Shader "Mechanist GUI/GUI, Loading Character"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {} 
	}

	Subshader
	{
		Tags {
			"Queue" = "Transparent"
		}

		Pass
		{
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
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
				float4 texcoord : TEXCOORD;
			};

			struct vertShader
			{
				// basics
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			vertShader vert(vertexInput v)
			{
				vertShader o;

				// pos and uv tex coord
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				
				return o;
			}

			fixed4 frag(vertShader i) : SV_Target{
				fixed4 outcolor = tex2D(_MainTex, i.uv1);
				return outcolor;
			}

			ENDCG
		}
	}
}