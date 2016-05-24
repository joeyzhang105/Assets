// Copyright Mechanist Games

Shader "Mechanist/07 - Solid, Opaque"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D ) = "white" {}
	}

	Subshader
	{	
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
      	 	Cull Back
      		
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
			
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma exclude_renderers flash d3d11
				
				struct VertInput
	            {
	                float4 vertex : POSITION;
	                float2 texcoord : TEXCOORD0;
			    };
				
				struct Varys
				{
					float4 pos : SV_POSITION;
					float2 uv1 : TEXCOORD0;
				};
				
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
				uniform fixed3 _TintColor;
																				
				Varys vert ( VertInput v )
				{
					Varys o;
					o.pos = mul (UNITY_MATRIX_MVP, v.vertex);	
					o.uv1 = TRANSFORM_TEX ( v.texcoord, _MainTex );
					return o;
				}
				
				fixed4 frag ( Varys i) : SV_Target {
					fixed3 outcolor = tex2D ( _MainTex, i.uv1 ) * _TintColor;
					return fixed4(outcolor,1);
				}
				
			ENDCG
		}
	}
}