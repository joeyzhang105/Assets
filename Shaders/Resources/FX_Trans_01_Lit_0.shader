// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist FX/Transparent/7 - Lit +0"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) 					= "white" {}
		_TintColor ("Tint Color", Color)				= (1,1,1,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		Cull Off
			
			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert
				#pragma fragment frag
				
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma exclude_renderers flash d3d11
				
				#include "UnityCG.cginc"
				#include "MechanistCG.cginc"
							
				struct VertInput
	            {
	                half4 vertex : POSITION;
	                half2 texcoord : TEXCOORD;
	            };
				
				struct Varys
				{
					half4 pos : SV_POSITION;
					half2 uv : TEXCOORD0;
				};
				
				uniform sampler2D 	_MainTex;
				uniform float4 		_MainTex_ST;
				uniform fixed4		_TintColor;
				
				Varys vert ( VertInput v )
				{
					Varys o;
						
					// pos and uv tex coord
					o.pos 	= mul (UNITY_MATRIX_MVP, v.vertex);
					o.uv 	= TRANSFORM_TEX ( v.texcoord, _MainTex );
					
					// probe
					float4 worldVertex = mul ( _Object2World, v.vertex );
					
					return o;
				}
				
				fixed4 frag ( Varys i) : SV_Target
				{
					fixed4 outcolor = tex2D ( _MainTex, i.uv);
					
					outcolor.rgb *= _Gbl_Amb + _Gbl_Lgt;
					
					return (outcolor * _TintColor);
				}
				
			ENDCG
		}
	}
	fallback "VertexLit"
}