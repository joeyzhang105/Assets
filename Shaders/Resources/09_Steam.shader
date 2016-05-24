// Copyright Mechanist Games
// Special thanks to Scott Host

Shader "Mechanist/09 - Wave Steam"
{
	Properties
	{
		_MainTex ("Texture, Color R, UV Modifier GB", 2D) = "white" {}
		_TintColor ("Tint Color", Color ) = (1,1,1,1)
		_UVModScroll ("UV Modifier, Speed XY", Vector) = (1,1,0,0)
		_ColorScroll  ("Color, Speed XY", Vector) = (1,1,0,0)
		_Distort ("UV Distortion, Amount XY", Vector ) = (0.1,0.1,0,0)
		_WaveDir ("Sine Wave Direction XYZ", Vector) = (1,1,1,1)
		_WaveLng ("Sine Wave Length XYZ", Vector) = (1,1,1,1)
		_WaveSpd ("Sine Wave Speed XYZ", Vector) = (1,1,1,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent+1"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
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
				fixed4 col : TEXCOORD2;
   				fixed fog : TEXCOORD3;
			};
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float2 _UVModScroll;
			uniform float2 _ColorScroll;
			uniform fixed4 _TintColor;
			uniform fixed2 _Distort;
			uniform float3 _WaveDir;
			uniform float3 _WaveLng;
			uniform float3 _WaveSpd;
			
			Varys vert ( VertInput v )
			{
				Varys o;
       			float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				float3 waveDir = _WaveDir * v.color.r;
				
				v.vertex.x += sin (_Time.y * _WaveSpd.x + worldVertex.y * _WaveLng.x) * waveDir.x;
				//v.vertex.y += sin (_Time.y * _WaveSpd.y + worldVertex.y * _WaveLng.y) * waveDir.y;
				v.vertex.z += sin (_Time.y * _WaveSpd.z + worldVertex.y * _WaveLng.z) * waveDir.z;
					
				// pos and uv tex coord
				o.pos 	= mul (UNITY_MATRIX_MVP, v.vertex);
				
				o.col = v.color;
				
				//scrolling
				o.uv1 = v.texcoord + ( _Time.x * _UVModScroll.xy );
				o.uv2 = v.texcoord * _MainTex_ST.xy + ( _Time.x * _ColorScroll.xy );
				
				// fog
				#ifdef QUALITY_HGH
					float fogDistance = 0.75 * length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
					fixed fogAmount = clamp ( fogDistance / _FogDistMax, 0, _FogClamp );
					o.fog = fogAmount;
				#endif
				
				return o;
			}
			
			fixed4 frag ( Varys i) : SV_Target
			{
				fixed2 uvMod = ( tex2D ( _MainTex, i.uv1 ).gb - fixed2 (0.5,0.5) ) * _Distort;
				fixed mainTex = tex2D ( _MainTex, i.uv2 + uvMod ).r;
				fixed4 outcolor = _TintColor * mainTex.rrrr;
				outcolor.a *= i.col.a;
				
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