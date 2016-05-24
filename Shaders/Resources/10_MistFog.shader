// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist/10 - Mist"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) = "white" {}
		_Direction ("Scroll Direction XY, XY", Vector ) = (0.3,0.1,0.1,0.3)
		_TintColor ("Tint Color", Color ) = (1,1,1,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent+1"
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
			
			
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
						
			struct VertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD;
            };
			
			struct Varys
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				fixed fog : TEXCOORD2;
				fixed alpha : TEXCOORD3;
			};
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Direction;
			uniform fixed4 _TintColor;
			
			Varys vert ( VertInput v )
			{
				Varys o;
					
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				//scrolling
				float2 uvBase = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv1 = uvBase + _Time.xx * _Direction.xy;
				o.uv2 = uvBase * 1.2 + _Time.xx * _Direction.zw;
				
				// fog
				#ifdef QUALITY_HGH
       				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
					float fogDistance = length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
					fixed fogAmount = clamp ( fogDistance / _FogDistMax, 0, _FogClamp );
					o.fog = fogAmount;
				#endif
				
				o.alpha = v.color.a;
				
				return o;
			}
			
			fixed4 frag ( Varys i) : SV_Target
			{
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor += tex2D ( _MainTex, i.uv2 );
				outcolor *= _TintColor;
				outcolor.a *= i.alpha;
				
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