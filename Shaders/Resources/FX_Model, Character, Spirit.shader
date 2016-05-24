// Copyright Mechanist Games

Shader "Mechanist FX/Character/ Spirit (贵)"
{
	Properties
	{
		_NormTex ("Norm Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (1,1,1,1)
		_TintColor2 ("Tint Color", Color) = (1,1,1,1)
	}

	Subshader
	{
		
		Tags {
			"Queue" = "Transparent+1"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
		}
		
		Pass
		{
      		ZWrite On
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
                half4 tangent : TANGENT;
                half2 texcoord	: TEXCOORD0;
            };
			
			struct vertShader
			{
				// basics
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				
				// frag lighting
			    half3 nrm : TEXCOORD1;
			    half3 tng : TEXCOORD2;
			    half3 bin : TEXCOORD3;
			    half3 cam : TEXCOORD4;
			};
				// properties
				uniform sampler2D _NormTex;
				uniform half4 _TintColor;
				uniform half4 _TintColor2;
				
			vertShader vert ( vertexInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord;
				
				// frag lighting
				o.nrm = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
				o.tng = normalize ( mul ( _Object2World, half4 ( v.tangent.xyz, 0.0 ) ).xyz );
            	o.bin = normalize ( cross ( o.nrm, o.tng ) * v.tangent.w );
            	o.cam = normalize ( WorldSpaceViewDir (v.vertex) );
				
				return o;
			}
			
			half4 frag ( vertShader i ) : SV_Target {
			
				// textures
				half3 bumpmap = tex2D (_NormTex, i.uv1) - half3(0.5,0.5,0.5);
				
				// normals
				half3x3 matrixDIR = half3x3 (i.tng, i.bin, i.nrm);
				half3 normDIR = normalize ( mul ( bumpmap, matrixDIR ) );
				
				// rim
				half rimlight = 1 - max ( 0, dot ( i.cam, normDIR ) );
				half4 outcolor = lerp(_TintColor,_TintColor2,rimlight) * half4(1,1,1,rimlight);
				
				return outcolor;
			}
				
			ENDCG
		}
	}
}