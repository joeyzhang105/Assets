
Shader "GTA/TextSmoothMask" 
{
	Properties 
	{
		_MainTex ("Font Texture", 2D) = "white" {}
		_Color ("Text Color", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
	}

	SubShader
	{

		Tags 
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}
		
		Lighting Off 
		Cull Off 
		ZTest [unity_GUIZTestMode]
		ZWrite Off 
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass 
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			float2 _LeftTop;
			float2 _RightBottom;
			float4 _MaskRect;
			float4 _OffsetRect;
			float4 _SmoothRect;
			float _Type;
			
			float2 SelfUVCalculate(float2 vertex)
			{
				float length = abs((_LeftTop - _RightBottom).x);
				float height = abs((_LeftTop - _RightBottom).y);
				float2 pos = vertex - _LeftTop;
				pos.y = pos.y + height;

				//return pos;
				return float2(pos.x/length, pos.y/height);
			}

			float MaskCalculate(float a, float2 uv)
			{
				if (uv.x <= _OffsetRect.z ||
					uv.x >= _OffsetRect.w ||
					uv.y <= _OffsetRect.y ||
					uv.y >= _OffsetRect.x)
					return 0;

				if (uv.x < _SmoothRect.z)
					a *= (uv.x - _OffsetRect.z) / (_SmoothRect.z - _OffsetRect.z);
				if (uv.x > _SmoothRect.w)
					a *= (_OffsetRect.w - uv.x) / (_OffsetRect.w - _SmoothRect.w);

				if (uv.y > _SmoothRect.x)
					a *= (_OffsetRect.x - uv.y) / (_OffsetRect.x - _SmoothRect.x);
				if (uv.y <  _SmoothRect.y)
					a *= (uv.y - _OffsetRect.y) / (_SmoothRect.y - _OffsetRect.y);

				return a;
			}

			struct appdata_t 
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1:TEXCOORD1;
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform fixed4 _Color;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord1 = v.vertex;
				o.color = v.color * _Color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
#ifdef UNITY_HALF_TEXEL_OFFSET
				o.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
#endif
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = i.color;
				col.a *= tex2D(_MainTex, i.texcoord).a;
				col.a = MaskCalculate(col.a, SelfUVCalculate(i.texcoord1));
				clip (col.a - 0.01);
				return col;
			}
			ENDCG 
		}
	}
}
