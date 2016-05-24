// Copyright Mechanist Games

Shader "Mechanist FX/Model/Dissolve, Additive"
{
	Properties
	{
		_MainTex ("Color Texture", 2D ) = "white" {}
		_DissTex ("Dissolve Texture", 2D ) = "white" {}
		_Dissolve ("Dissolve", Range (-0.1,1)) = 0
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
      	 	Blend SrcAlpha One
      		Cull Back
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
			uniform sampler2D _DissTex;
			uniform half4 _DissTex_ST;
			
			// properties
			uniform half4 _CoreColor;
			uniform half4 _GlowColor;
			uniform half _Dissolve;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord1, _MainTex );
				o.uv2 = TRANSFORM_TEX ( v.texcoord1, _DissTex );
																																		
				return o;
			}
						
			half4 frag ( vertShader i ) : SV_Target {
				
				half3 baseTex = tex2D ( _MainTex, i.uv1 );
				half dissolve = smoothstep ( _Dissolve, _Dissolve + 0.1, tex2D ( _DissTex, i.uv2 ).r );
				
				half4 outcolor = half4 ( baseTex, dissolve );
				
				return outcolor;
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}