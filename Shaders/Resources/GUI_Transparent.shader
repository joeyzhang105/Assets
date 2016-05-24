// Copyright Mechanist Games

Shader "Mechanist GUI/GUI, Transparent"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Selected("Selected (0,1)", Range(0, 1)) = 0
		_Grayscale("Grayscale (0,1)", Range(0, 1)) = 1
		[HideInInspector]	_ColorMask("Color Mask", Float) = 15
		[HideInInspector]	_StencilComp("Stencil Comparison", Float) = 8
		[HideInInspector]	_Stencil("Stencil ID", Float) = 0
		[HideInInspector]	_StencilOp("Stencil Operation", Float) = 0
		[HideInInspector]	_StencilWriteMask("Stencil Write Mask", Float) = 255
		[HideInInspector]	_StencilReadMask("Stencil Read Mask", Float) = 255
}

	Subshader
	{
		LOD 100

		Tags{ "QUEUE" = "Transparent" "IGNOREPROJECTOR" = "true" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "true" }

		Pass
		{
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			Lighting Off
			Fog{ Mode Off }
			Stencil{
				Ref[_Stencil]
				ReadMask[_StencilReadMask]
				WriteMask[_StencilWriteMask]
				Comp[_StencilComp]
				Pass[_StencilOp]
			}
			ColorMask[_ColorMask]

				CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag

#pragma glsl
#pragma glsl_no_auto_normalization
#pragma fragmentoption ARB_precision_hint_fastest
#pragma exclude_renderers flash d3d11

#include "UnityCG.cginc"

			struct vertexInput
			{
				half4 vertex : POSITION;
				half2 texcoord0 : TEXCOORD0;
			};

			struct vertShader
			{
				// basics
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			};
			// assets
			uniform sampler2D _MainTex;

			// properties
			uniform half _Selected;
			uniform half _Grayscale;

			vertShader vert(vertexInput v)
			{
				vertShader o;
				half3 worldVertex = mul(_Object2World, v.vertex).xyz;

				// pos and uv tex coord
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;

				return o;
			}

			half4 frag(vertShader i) : SV_Target{

				half4 outcolor = tex2D(_MainTex, i.uv1) * (1 + _Selected);
				half grayscale = (outcolor.r + outcolor.g + outcolor.b) * 0.333;
				outcolor.rgb = lerp(outcolor.rgb, grayscale.xxx, _Grayscale);

				return outcolor;
			}

			ENDCG
		}
	}
	//FallBack "VertexLit"
}