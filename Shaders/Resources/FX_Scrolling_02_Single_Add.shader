// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist FX/Scrolling/2 - Single Additive"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) 					= "white" {}		
		_DirectionX ("Scroll Direction X", Float )			= 10
		_DirectionY ("Scroll Direction Y", Float )			= 10
		_TintColor ("Tint Color", Color )					= (1,1,1,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha One
      		Cull Off
      		Lighting Off
      		Fog {Mode Off}
			
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
				uniform float		_DirectionX;
				uniform float		_DirectionY;
				uniform fixed4		_TintColor;
				
				Varys vert ( VertInput v )
				{
					Varys o;
						
					// pos and uv tex coord
					o.pos 	= mul (UNITY_MATRIX_MVP, v.vertex);
					o.uv 	= TRANSFORM_TEX ( v.texcoord, _MainTex );
					
					//scrolling
					o.uv.x += _Time.x * _DirectionX;
					o.uv.y += _Time.x * _DirectionY;
					
					return o;
				}
				
				fixed4 frag ( Varys i) : SV_Target
				{
					return tex2D ( _MainTex, i.uv ) * _TintColor;
				}
				
			ENDCG
		}
	}
	//fallback "VertexLit"
}