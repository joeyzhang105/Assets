// Copyright Mechanist Games

Shader "Mechanist/78 - GroundGrid"
{
	Properties
	{
	_LineColor("Line Color", Color) = (1, 1, 1, 1)
	_BaseTex("R Texture", 2D) = "black" {}
	_GridSize("GridSize", Float) = 1
		_BorderWidth("LineWidth", Float) = 0.1
}

	Subshader
	{
		Tags{
		"Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"LightMode" = "Always"
		"ForceNoShadowCasting" = "True"
	}

		Pass
		{

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			Fog{ Mode Off }

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

			struct vertInput
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
			};

			// properties
			uniform sampler2D _BaseTex;
			float4 _LineColor;
			float _BorderWidth;
			float _GridSize;

			vertShader vert(vertInput v)
			{
				vertShader o;
				float3 worldVertex = mul(_Object2World, v.vertex).xyz;
				float2 worldUV = worldVertex.xz;

				// pos and uv tex coord
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV;

				return o;
			}

			fixed4 frag(vertShader i) : SV_Target{

				float temp1 = fmod(i.uv1.x + 100000, _GridSize);
				float temp2 = fmod(i.uv1.y + 100000, _GridSize);
				if (temp1 < _BorderWidth){
					return _LineColor;
				}
				else if (temp2 < _BorderWidth){
					return _LineColor;
				}
				else{
					return fixed4(1, 1, 1, 0);
				}
			}
			ENDCG
		}
	}
	//FallBack "Diffuse"
}