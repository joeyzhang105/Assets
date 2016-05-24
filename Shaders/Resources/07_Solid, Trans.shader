// Copyright Mechanist Games

Shader "Mechanist/07 - Solid, Alpha"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (1,1,1,1)
	}

	Subshader
	{	
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
      	 	Cull Back
      	 	//ZWrite On
      	 	//ZTest On
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		
			CGPROGRAM
				
				//=============================================
				
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				
				//=============================================
				
				struct VertInput
	            {
	                float4 vertex : POSITION;
	                float2 texcoord : TEXCOORD0;
			    };
				
				//=============================================
				
				struct Varys
				{
					half4 pos : SV_POSITION;
				};
				
				//=============================================
				
				uniform fixed4 _TintColor;
				
				//=============================================
																				
				Varys vert ( VertInput v )
				{
					Varys o;
					o.pos = mul (UNITY_MATRIX_MVP, v.vertex);																				
					return o;
				}
				
				//=============================================
				
				fixed4 frag ( Varys i) : SV_Target {
					return fixed4(_TintColor);
				}
				
				//=============================================
				
			ENDCG
		}
	}
}