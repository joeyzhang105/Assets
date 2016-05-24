// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist/09 - Glow Shark"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) 					= "white" {}
		_TintColor ("Tint Color", Color)				= (1,1,1,1)
		_Move ("Shark Movement", Vector) = (0.1,0.1,0.1,0.1)
		_Speed ("Shark Speed", Range(0,5)) = 1
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent-4"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
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
			
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
						
			struct VertInput
            {
                float4 vertex		: POSITION;
                float2 texcoord		: TEXCOORD;
            };
			
			struct Varys
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
   				fixed fog : TEXCOORD1;
			};
			
			uniform sampler2D 	_MainTex;
			uniform float4 		_MainTex_ST;
			uniform float4 		_Move;
			uniform float 		_Speed;
			uniform fixed4		_TintColor;
			
			Varys vert ( VertInput v )
			{
				Varys o;
				
				v.texcoord.x += _Move.x * 0.05 * sin (_Time.z * _Speed + v.texcoord.y * _Move.y);
				v.texcoord.y += _Move.z * 0.05 * sin (_Time.z * _Speed + v.texcoord.x * _Move.w);
				
				// pos and uv tex coord
				o.pos 	= mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv 	= TRANSFORM_TEX ( v.texcoord, _MainTex );
				
				// fog
				#ifdef QUALITY_HGH
       				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
					float fogDistance = 0.75 * length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
					fixed fogAmount = clamp ( fogDistance / _FogDistMax, 0, _FogClamp );
					o.fog = fogAmount;
				#endif
				
				return o;
			}
			
			fixed4 frag ( Varys i) : SV_Target {
			
				fixed4 outcolor = tex2D ( _MainTex, i.uv ) * _TintColor;
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.a *= 1 - i.fog;
				#endif
				
				return outcolor;
			}
			
			ENDCG
		}
	}
	//fallback "VertexLit"
}