// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist/10 - Global Color Flames"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) 					= "white" {}
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
			
			Varys vert ( VertInput v )
			{
				Varys o;
					
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
			
				fixed4 outcolor = tex2D ( _MainTex, i.uv ) * fixed4(_Gbl_Pnt,1);
				
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