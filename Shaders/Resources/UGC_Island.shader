// Copyright Mechanist Games

Shader "Mechanist MAP/UGC Island"
{
	Properties
	{
		_UGC_Curvature ("UGC Curvature", Float) = 0.001
		_BaseTiling ("Base Tiling", Float) = 1
		_RedTex ("Color Texture", 2D) = "white" {}
		_GreenTex ("Color Texture", 2D) = "white" {}
		_BlueTex ("Color Texture", 2D) = "white" {}
		_AlphaTex ("Color Texture", 2D) = "white" {}
		_SpecTex ("Spec Texture", 2D) = "white" {}
		_CastleFog ("Fog Color", Color) = (0.4,0.6,0.8,1)
		_FogUpper ("Fog Upper Limit", Float) = 24
		_FogLower ("Fog Lower Limit", Float) = 17
	}

	Subshader
	{
	
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
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
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
                float2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vtc : TEXCOORD3;
				fixed3 sun : TEXCOORD4;
				fixed shd : TEXCOORD5;
				fixed3 col : TEXCOORD6;
				fixed fog : TEXCOORD7;
			};
			
			// resources
			uniform sampler2D _RedTex;
			uniform sampler2D _GreenTex;
			uniform sampler2D _BlueTex;
			uniform sampler2D _AlphaTex;
			uniform sampler2D _SpecTex;
			
			// local properties
			uniform float _BaseTiling;
			uniform fixed3 _SunColor;
			uniform fixed3 _MoonColor;
			uniform fixed3 _CastleFog;
			uniform float _FogUpper;
			uniform float _FogLower;
			
			// global properties
			uniform float3 _UGC_MapCenter;
			uniform float _UGC_Curvature;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
               	float3 worldNormal = normalize ( mul ( float4 ( lerp(v.normal,float3(0,0.9,0),v.color.r), 0.0 ), _World2Object ).xyz );
               	float3 worldMoonLgt = float3(-_WorldSpaceLightPos0.x,_WorldSpaceLightPos0.y,-_WorldSpaceLightPos0.z);
				
				// lighting
				float sundot = pow ( max ( 0, dot(_WorldSpaceLightPos0, worldNormal) ), 3);
				float moondot = max ( 0, dot( worldMoonLgt, worldNormal) );
				float cutoff = clamp(v.vertex.y, 0, 1);
				o.sun = 1 + (_SunColor * sundot * 2 + _MoonColor * pow(moondot,2) * 2) * cutoff;
				o.shd = 1 - moondot * cutoff;

				// fog
				o.fog = smoothstep ( _FogUpper, _FogLower, worldVertex.y);

				// curvature
               	float3 totalDist = distance ( _UGC_MapCenter, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _UGC_Curvature;
				float distanceZ = totalDist.z * totalDist.z * _UGC_Curvature;
				v.vertex.y -= distanceX + distanceZ;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0 * _BaseTiling;
				
				// sun glow
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 cloudUV = (worldVertex.xz - _UGC_MapCenter.xz) * fixed2(-0.007, -0.007);
				o.uv2 = mul ( cloudUV, rotMat ) + float2(0.5,0.5);
				
				// vertex colors
				o.vtc = v.color;

				// color
				o.col = smoothstep ( 0, 150, distance( _UGC_MapCenter , worldVertex ));

				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
				
				// color
				fixed3 outcolor = tex2D ( _RedTex, i.uv1 ) * i.vtc.r;
				
				// splatmap
				outcolor += tex2D ( _GreenTex, i.uv1 ) * i.vtc.g;
				outcolor += tex2D ( _BlueTex, i.uv1 ) * i.vtc.b;
				outcolor += tex2D ( _AlphaTex, i.uv1 ) * i.vtc.a;
				
				// directional light
				outcolor *= 0.666 + 0.333 * smoothstep(0.75,0.85,i.shd);
				outcolor *= i.sun;

				// fog
				outcolor.rgb = lerp(outcolor, _CastleFog, i.fog);

				// global light
				fixed4 spccolor = tex2D ( _SpecTex, i.uv2 );
				outcolor = lerp (outcolor, spccolor.rgb, spccolor.a);
				
				return fixed4 (outcolor.rgb,1);	
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}