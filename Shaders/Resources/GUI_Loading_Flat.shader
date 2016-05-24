// Copyright Mechanist Games

Shader "Mechanist GUI/GUI, Loading Flat"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
	}

	Subshader
	{
		Tags {
			"QUEUE" = "Geometry"
		}

		Pass
		{
			Cull Back
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
			};
			
			// local properties
			uniform fixed3 _Color;

			vertShader vert(vertexInput v)
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				return o;
			}

			fixed4 frag(vertShader i) : SV_Target{
				return fixed4(_Color,1);
			}

			ENDCG
		}
	}
	FallBack "VertexLit"
}