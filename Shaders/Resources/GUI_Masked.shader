Shader "Mechanist GUI/Masked"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_Clip ("Clipping [-X, X, -Y, Y]", Vector) = (0,0,0,0)
		_Corner ("Corners", range(5,35)) = 20
		_Softness ("Softness", range(0,0.05)) = 0.025
	}

	SubShader
	{
		
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Clip;
			float _Corner;
			float _Softness;

			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : POSITION;
				half4 vtc : COLOR;
				float2 uv1 : TEXCOORD0;
				float4 uvS : TEXCOORD1;
			};

			v2f o;

			v2f vert (appdata_t v)
			{  	
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.vtc = v.color;
				o.uv1 = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				
				// clip ranges
               	o.uvS = ComputeScreenPos(o.pos);
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv1);
				fixed2 uvS = (i.uvS.xy / i.uvS.ww);
				fixed2 uvN = 1 - uvS;
				
				// steps
				fixed alphaX = clamp ( ( uvS.x - _Clip.x - 0.5) * ( uvN.x + _Clip.y - 0.5) * _Corner, 0, 1);
				fixed alphaY = clamp ( ( uvS.y - _Clip.z - 0.5) * ( uvN.y + _Clip.w - 0.5) * _Corner, 0, 1);
				col.a *= smoothstep( 0.01, 0.01 + _Softness, alphaX * alphaY );
				return col;
			}
			ENDCG
		}
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
