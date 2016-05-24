// Copyright Mechanist Games

Shader "Mechanist CITY/Water"
{
	Properties
	{
		_MainTex ("Under Texture", 2D) = "white" {}
		_WaterTex ("Water Texture", 2D) = "white" {}
		_WaterColor ("Water Color", Color) = (1,1,1,1)
		_SpecuColor ("Specular Color", Color) = (1,1,1,1)
		_DistortAmount ("Refraction", Float) = 0.005
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
      		Cull Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				float3 cam : TEXCOORD3;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(4)
				#endif
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _WaterTex;
			uniform float4 _MainTex_ST;
			uniform float4 _WaterTex_ST;
			
			// properties
			uniform fixed3 _WaterColor;
			uniform fixed3 _SpecuColor;
			uniform float _DistortAmount;
			
			uniform fixed _TotalBrightness;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord1, _MainTex );
				
				// diffuse reflection
               	float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				o.cam = normalize ( WorldSpaceViewDir (v.vertex) );
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				o.uv2 = TRANSFORM_TEX ( v.texcoord0, _WaterTex ) + _Time.x * 0.6;
				o.uv3 = o.uv2 * 0.8 - _Time.x * 0.7;
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed3 waternrm = tex2D ( _WaterTex, i.uv2 ) - tex2D ( _WaterTex, i.uv3 );
				waternrm = normalize(fixed3(waternrm.r,0.333,waternrm.g));
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 + waternrm.rb * _DistortAmount );
				
				// shadows
				#if !defined (SHADOWS_OFF)
					fixed shadow = 0.7 + 0.4 * SHADOW_ATTENUATION(i);
				#else
					fixed shadow = 0.7 + 0.4;
				#endif
				outcolor.rgb *= shadow;
				
				
				// specular
				outcolor.rgb *= _WaterColor.rgb + 0.5 * waternrm.rrr * waternrm.bbb;
				outcolor.rgb += pow ( max ( 0, dot ( waternrm, i.cam ) ), 30 ) * _SpecuColor.rgb;
				
				return outcolor * _TotalBrightness;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}