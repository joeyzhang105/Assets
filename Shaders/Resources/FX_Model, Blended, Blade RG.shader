// Copyright Mechanist Games

Shader "Mechanist FX/Model/Blended, Blade RG"
{
	Properties
	{
		_CoreColor ("Core Color", Color) = (1,0,0,1)
		_GlowColor ("Glow Color", Color) = (0,1,0,1)
		_Alpha ("Alpha", Range(0,1)) = 1
		_MainTex ("R Core, G Glow", 2D ) = "white" {}
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
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
                half4 vertex : POSITION;
                half2 texcoord1 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			
			// properties
			uniform half4 _CoreColor;
			uniform half4 _GlowColor;
			uniform half _Alpha;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord1, _MainTex );
																																		
				return o;
			}
						
			half4 frag ( vertShader i ) : SV_Target {
				
				half2 baseTex = tex2D ( _MainTex, i.uv1 );
				half4 outcolor = baseTex.r * _CoreColor + baseTex.g * _GlowColor;
				outcolor.a *= _Alpha;
				return outcolor;
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}