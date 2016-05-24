// Copyright Mechanist Games

Shader "Mechanist FX/Character/Trail, Additive"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_Color ("Tint Color", Color) = (1,1,1,1)
	}

	Subshader
	{
		
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
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
			#include "MechanistCG.cginc"
			
			struct vertexInput
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord	: TEXCOORD0;
            };
			
			struct vertShader
			{
				// basics
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			    half rim : TEXCOORD1;
			};
			
			// properties
			uniform sampler2D _MainTex;
			uniform half4 _Color;
				
			vertShader vert ( vertexInput v )
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord;
            	
            	// rim
				half rim = 1 - max ( 0 , pow ( dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ), 2 ) );
				o.rim = 0.333 + 0.666 * rim;
				
				return o;
			}
			
			half4 frag ( vertShader i ) : SV_Target {
			
				half3 basecolor = tex2D (_MainTex, i.uv1);
				half3 outcolor = lerp (basecolor, _Color.rgb, i.rim);
				
				return half4(outcolor,_Color.a);
			}
				
			ENDCG
		}
	}
}