// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist FX/World/Scrolling Additive"
{
	Properties
	{
		_Curvature ("World Curvature", Float) = 0.0012
		_MainTex1 ("Color Texture, RGB", 2D) 				= "white" {}
		_TintColor ("Tint Color", Color )					= (1,1,1,1)
		_RGBscrollX ("Color Direction X (-1/+1)", Float)	= 0
		_RGBscrollY ("Color Direction Y (-1/+1)", Float)	= 0
		_MainTex2 ("Mask, Greyscale", 2D) 					= "white" {}
		_AscrollX ("Mask Direction X (-1/+1)", Float)		= 0
		_AscrollY ("Mask Direciton Y (-1/+1)", Float)		= 0
		_Speed ("Scrolling Speed (10)", Float )			= 10
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
					half4 pos			: SV_POSITION;
					half2 uv1 			: TEXCOORD0;
					half2 uv2 			: TEXCOORD1;
				};
				
				uniform sampler2D 	_MainTex1;
				uniform float4 		_MainTex1_ST;
				uniform sampler2D	_MainTex2;
				uniform float4 		_MainTex2_ST;
				uniform float		_RGBscrollX;
				uniform float		_RGBscrollY;
				uniform float		_AscrollX;
				uniform float		_AscrollY;
				uniform float		_Speed;
				uniform fixed4		_TintColor;
				uniform float3 _CameraFocalPoint;
				uniform float _Curvature;
				
				Varys vert ( VertInput v )
				{
					Varys o;
					
					// curvature
					float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
					float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
					float distanceX = totalDist.x * totalDist.x * _Curvature;
					float distanceZ = totalDist.z * totalDist.z * _Curvature;
					v.vertex.y -= distanceX + distanceZ;
						
					// pos and uv tex coord
					o.pos 	= mul (UNITY_MATRIX_MVP, v.vertex);
					o.uv1 	= TRANSFORM_TEX ( v.texcoord, _MainTex1 );
					o.uv2 	= TRANSFORM_TEX ( v.texcoord, _MainTex2 );
					
					//scrolling
					o.uv1.x += _Time.x * _RGBscrollX * _Speed;
					o.uv1.y += _Time.x * _RGBscrollY * _Speed;
					o.uv2.x += _Time.x * _AscrollX * _Speed;
					o.uv2.y += _Time.x * _AscrollY * _Speed;
					
					return o;
				}
				
				fixed4 frag ( Varys i) : SV_Target
				{
					fixed4 TexA = tex2D ( _MainTex1, i.uv1 );
					fixed3 TexB = tex2D ( _MainTex2, i.uv2 );
					
					return fixed4( TexA.rgb, TexA.a * TexB.r) * _TintColor;
				}
				
			ENDCG
		}
	}
	//fallback "VertexLit"
}