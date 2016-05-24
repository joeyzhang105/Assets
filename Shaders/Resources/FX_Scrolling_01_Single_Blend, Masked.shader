// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist FX/Scrolling/1 - Single Blended Masked"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) = "white" {}
		_MaskTex ("Alpha Mask Texture", 2D) = "white" {}
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
      	 	Blend SrcAlpha OneMinusSrcAlpha
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
	                float4 vertex : POSITION;
	                float4 color : COLOR;
	                float2 texcoord : TEXCOORD;
	            };
				
				struct Varys
				{
					float4 pos : SV_POSITION;
					float2 uv1 : TEXCOORD0;
					float4 vtc : TEXCOORD1;
				};
				
				uniform sampler2D 	_MainTex;
				uniform sampler2D 	_MaskTex;
				uniform float4 		_MainTex_ST;
				uniform float		_DirectionX;
				uniform float		_DirectionY;
				uniform fixed4		_TintColor;
				
				Varys vert ( VertInput v )
				{
					Varys o;
						
					// pos and uv tex coord
					o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
					o.uv1 = TRANSFORM_TEX ( v.texcoord, _MainTex );
					
					// vertex color
					o.vtc = v.color;
					
					//scrolling
					o.uv1.x += _Time.x * _DirectionX;
					o.uv1.y += _Time.x * _DirectionY;
					
					return o;
				}
				
				fixed4 frag ( Varys i) : SV_Target
				{
					fixed4 outcolor = tex2D ( _MainTex, i.uv1 ) * _TintColor;
					outcolor.a *= i.vtc.a;
					return outcolor;
				}
				
			ENDCG
		}
	}
	//fallback "VertexLit"
}