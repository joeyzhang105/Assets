// Copyright Mechanist Games

Shader "Mechanist MAP/Aura"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint Color", Color) = (1,1,1,1)
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha One
      		Cull Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
			struct VertInput
            {
                half4 vertex : POSITION;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				fixed glo : TEXCOORD1;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform fixed4 _Color;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord0, _MainTex );
				
				o.glo = 1 + 0.1 * sin (_Time.w);
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 ) * _Color * i.glo;
				return outcolor;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}