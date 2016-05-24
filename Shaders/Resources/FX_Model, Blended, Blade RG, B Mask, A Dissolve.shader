// Copyright Mechanist Games

Shader "Mechanist FX/Model/Blended, Blade RG, B Mask, A Dissolve"
{
	Properties
	{
		_CoreColor ("Core Color", Color) = (1,0,0,1)
		_GlowColor ("Glow Color", Color) = (0,1,0,1)
		_Dissolve ("Dissolve", Range (0,1)) = 0
		_Hardness ("Dissolve Edge", Range (0,0.3)) = 0.15
		_worldUVScroll ("Dissolve Move", Range(0,10)) = 5
		_worldUVScale ("Dissolve Scale", Float) = 1
		_CoreFade ("Core Stay", Range (0,0.7)) = 0.35
		_MainTex ("R Core, G Glow, B Mask, A Dissolve", 2D ) = "white" {}
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
				half2 uv2 : TEXCOORD1;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			
			// properties
			uniform half4 _CoreColor;
			uniform half4 _GlowColor;
			uniform half _Dissolve;
			uniform half _Hardness;
			uniform half _CoreFade;
			uniform half _worldUVScroll;
			uniform half _worldUVScale;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord1, _MainTex );
				o.uv2 = o.uv1 * _worldUVScale + _Time.x * _worldUVScroll;
																																		
				return o;
			}
						
			half4 frag ( vertShader i ) : COLOR {
				
				half3 baseTex = tex2D ( _MainTex, i.uv1 ).rgb;
				half worldDiss = baseTex.b * ( baseTex.r * _CoreFade + tex2D ( _MainTex, i.uv2 ).a );
				half4 outcolor = baseTex.r * _CoreColor + baseTex.g * _GlowColor;
				worldDiss = smoothstep (_Dissolve - _Hardness,_Dissolve, worldDiss );
				outcolor += 2 * baseTex.g * worldDiss * (1 - worldDiss);
				outcolor.a *= worldDiss;
				
				return outcolor;
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}