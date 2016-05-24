// Copyright Mechanist Games

Shader "Mechanist/00 - Items"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_NormTex ("Norm Texture", 2D) = "white" {}
		_ChanTex ("Spec Texture", 2D) = "white" {}
	}

	Subshader
	{
		
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
		}
		
		Pass
		{
      		Cull Back
      		Fog {Mode Off}
      		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
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
				half1 shd : TEXCOORD5;
				half3 ref : TEXCOORD7;
			
			};
				// assets
				uniform sampler2D _MainTex;
				uniform sampler2D _NormTex;
				uniform sampler2D _ChanTex;
				uniform samplerCUBE _CubeMap;
				
				// properties
				uniform half _Hit;
				uniform half _BaTi;
				
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
            	o.ref = normalize ( worldVertex - _WorldSpaceCameraPos );
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
				// textures
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 );
				fixed3 channels = tex2D ( _ChanTex, i.uv1 );
				fixed3 bumpmap = tex2D ( _NormTex, i.uv1 ) - half3(0.5,0.5,0.5);
				
				// normals
				fixed3x3 matrixDIR = half3x3 (i.tng, i.bin, i.nrm);
				fixed3 normDIR = normalize ( mul ( bumpmap, matrixDIR ) );
				
				// spec, rim
				fixed dotprod = max ( 0, dot ( i.cam, normDIR ) );
				fixed spclight = pow ( dotprod, 30 ) * channels.r * 6;
				fixed rimlight = pow ( 1 - dotprod, 2 ) * channels.b * 3;
				
				// composite
				outcolor *= 0.5 + spclight + rimlight;
				
				return fixed4 (outcolor.rgb,1);
			}
				
			ENDCG
		}
	}
	FallBack "VertexLit"
}