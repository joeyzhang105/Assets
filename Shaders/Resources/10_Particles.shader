// Copyright Mechanist Games

Shader "Mechanist/10 - Global Lit Particles"
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
			
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
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
				fixed4 lgt : TEXCOORD1;
	   			fixed fog : TEXCOORD2;
			};
			
			// resources
			uniform sampler2D _MainTex;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				
				// vertex lights
				o.lgt = v.color;
				o.lgt.rgb *= _Gbl_Amb + 0.666 * _Gbl_Lgt;
				
				// fog
//				#ifdef QUALITY_HGH
//               	float3 worldVertex = mul ( UNITY_MATRIX_P, v.vertex ).xyz;
//					float fogDistance =  length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
//					fixed fogAmount = clamp ( fogDistance / _FogDistMax, 0, _FogClamp );
//					o.fog = fogAmount;
//				#endif
				
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor *= i.lgt;
				
				// fog
//				#ifdef QUALITY_HGH
//					outcolor.a *= 1 - i.fog;
//				#endif
				
				return outcolor;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}