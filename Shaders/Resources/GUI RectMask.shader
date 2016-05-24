Shader "Mechanist GUI/RectMask"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_Vector4("Rect" , Vector)=(1,1,1,1)
		_Value("Value",Range(0,1000))=0
	}
	
	SubShader
	{
		LOD 200

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
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag		
      		#define iResolution _ScreenParams  
   			#define gl_FragCoord ((IN.scrPos.xy/IN.scrPos.w)*_ScreenParams.xy)   	
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Vector4;
			float _Value;
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 scrPos:TEXCOORD1;
				fixed4 color : COLOR;
			};
	
			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				o.scrPos=ComputeScreenPos(v.vertex);
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f IN) : SV_Target
			{
			//float2 vect2=IN.vertex.xy/IN.vertex.w;
			fixed2 vect2 = (IN.scrPos.xy/IN.scrPos.w);
			fixed4 outcolor=tex2D(_MainTex, IN.texcoord) * IN.color;	

			outcolor.a *= clamp(sign(vect2.x + _Vector4.z*0.5 - _Vector4.x), 0.0, 1.0);
			outcolor.a *= clamp(sign(_Vector4.x + _Vector4.z*0.5 - vect2.x), 0.0, 1.0);
			outcolor.a *= clamp(sign(vect2.y + _Vector4.w*0.5 - _Vector4.y), 0.0, 1.0);
			outcolor.a *= clamp(sign(_Vector4.y + _Vector4.w*0.5 - vect2.y), 0.0, 1.0);
	
			return outcolor;

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
			Offset -1, -1
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
