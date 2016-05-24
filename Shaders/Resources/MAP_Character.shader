// Copyright Mechanist Games

Shader "Mechanist MAP/Character"
{
	Properties
	{
		//_CurveDir ("World Curve Vector", Vector) = (0,-1,0,0)
		_MainTex ("Base Texture", 2D) = "white" {}
		_NormTex ("Norm Texture", 2D) = "white" {}
		_ChanTex ("Spec Texture", 2D) = "white" {}
		_CubeMap ("Cube Map", CUBE) = "white" {}
	}

	Subshader
	{
		
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
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
				half1 shd : TEXCOORD5;
				half3 ref : TEXCOORD6;
			
			};
			
			// assets
			uniform sampler2D _MainTex;
			uniform sampler2D _NormTex;
			uniform sampler2D _ChanTex;
			uniform samplerCUBE _CubeMap;
			
			// local properties
			//uniform float3 _CurveDir;
			
			// global properties
			uniform float3 _CameraFocalPoint;
			uniform float _Curvature;
			uniform fixed3 _SunColor;
			uniform fixed3 _MoonColor;
			uniform fixed3 _OceanMidColor;
			
			vertShader vert ( vertexInput v )
			{
				vertShader o;
               	half4 worldVertex = mul ( _Object2World, v.vertex );
               	float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				
				// curvature
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				worldVertex.y -= distanceX + distanceZ;
				v.vertex = mul(_World2Object, worldVertex);
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord;
				
				// frag lighting
				o.nrm = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
				o.tng = normalize ( mul ( _Object2World, half4 ( v.tangent.xyz, 0.0 ) ).xyz );
            	o.bin = normalize ( cross ( o.nrm, o.tng ) * v.tangent.w );
            	o.cam = normalize ( WorldSpaceViewDir (v.vertex) );
            	o.ref = normalize ( worldVertex - _WorldSpaceCameraPos );
            	o.shd = max ( 0, dot ( _WorldSpaceLightPos0, normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz ) ) );
				
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
				
				// reflection
				fixed3 reflDIR = reflect ( i.ref, normDIR );
				fixed3 reflight = texCUBE( _CubeMap, reflDIR );
				reflight *= 0.5 + outcolor;
				outcolor = lerp ( outcolor, reflight, channels.g);
				
				// shadow
				fixed shdlight = smoothstep( 0.1, 0.15, i.shd * channels.b );
				outcolor *= 0.7 + 0.4 * shdlight;
				
				// spec, rim
				fixed dotprod = max ( 0, dot ( i.cam, normDIR ) );
				fixed spclight = pow ( dotprod, 30 ) * channels.r * 5;
				fixed rimlight = pow ( 1 - dotprod, 2 ) * channels.r * 2;
				outcolor *= 1.1 + _SunColor * spclight + _OceanMidColor * rimlight;
				
				return fixed4 (outcolor.rgb,1);
			}
				
			ENDCG
		}
	}
	//FallBack "VertexLit"
}