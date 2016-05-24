// Copyright Mechanist Games

Shader "Mechanist FX/Particles/Ambient - Additive"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
		
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
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
			#include "MechanistCG.cginc"
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				fixed4 lgt : TEXCOORD2;
			};
			
			// resources
			uniform sampler2D _MainTex;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	//float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				
				// vertex lights
				o.lgt = v.color;
				o.lgt.rgb *= _Gbl_Amb + 0.666 * _Gbl_Lgt;
				
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor *= i.lgt;
				return outcolor;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}