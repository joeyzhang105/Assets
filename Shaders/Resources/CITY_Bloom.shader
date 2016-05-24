// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist CITY/Bloom"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) 					= "white" {}
		_TintColor ("Tint Color", Color)				= (1,1,1,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent+1"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
		}
		
		Pass
		{
			ZWrite Off
			ZTest Off
      	 	Blend SrcAlpha One
      		Cull Off
      		Lighting Off
			
			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert
				#pragma fragment frag
				
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma exclude_renderers flash d3d11
				
				#include "UnityCG.cginc"
							
				struct VertInput
	            {
	                float4 vertex		: POSITION;
	                float2 texcoord		: TEXCOORD;
	            };
				
				struct Varys
				{
					float4 pos			: SV_POSITION;
					float2 uv 			: TEXCOORD0;
				};
				
				uniform sampler2D 	_MainTex;
				uniform float4 		_MainTex_ST;
				uniform fixed4		_TintColor;
				
				// disabler
				uniform float _CityBloom;
				
				Varys vert ( VertInput v )
				{
					Varys o;
						
					// pos and uv tex coord
					o.pos 	= mul (UNITY_MATRIX_MVP, v.vertex);
					o.uv 	= TRANSFORM_TEX ( v.texcoord, _MainTex );
					
					return o;
				}
				
				fixed4 frag ( Varys i) : SV_Target
				{
					fixed4 outcolor = tex2D ( _MainTex, i.uv ) * _TintColor;
					outcolor *= _CityBloom;
					return outcolor;
				}
				
			ENDCG
		}
	}
	//fallback "VertexLit"
}