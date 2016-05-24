// Copyright Mechanist Games

Shader "Mechanist MAP/Island Cliffs"
{
	Properties
	{
		_BaseTiling ("Base Tiling", Float) = 1
		_WallTiling ("Cliff Tiling", Vector) = (1,1,0,0)
		_BaseTex ("Color Texture", 2D) = "white" {}
		_RockTex ("Rock Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_SpecTex ("Spec Texture", 2D) = "white" {}
	}

	Subshader
	{
		LOD 100
	
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
                float2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				float2 uv4 : TEXCOORD3;
				float4 vtc : TEXCOORD4;
				fixed3 sun : TEXCOORD5;
				fixed shd : TEXCOORD6;
			};
			
			// resources
			uniform sampler2D _BaseTex;
			uniform sampler2D _RockTex;
			uniform sampler2D _MaskTex;
			uniform sampler2D _SpecTex;
			
			// local properties
			uniform float _BaseTiling;
			uniform float2 _WallTiling;
			
			// global properties
			uniform float3 _CameraFocalPoint;
			uniform float _Curvature;
			uniform fixed3 _MappyAmbient;
			uniform fixed3 _SunColor;
			uniform fixed3 _MoonColor;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
               	float3 worldNormal = normalize ( mul ( float4 ( lerp(v.normal,float3(0,0.9,0),v.color.r), 0.0 ), _World2Object ).xyz );
               	float3 worldMoonLgt = float3(-_WorldSpaceLightPos0.x,_WorldSpaceLightPos0.y,-_WorldSpaceLightPos0.z);
               	float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				
				// lighting
				float sundot = pow ( max ( 0, dot(_WorldSpaceLightPos0, worldNormal) ), 3);
				float moondot = max ( 0, dot( worldMoonLgt, worldNormal) );
				float cutoff = clamp(v.vertex.y, 0, 1);
				o.sun = 1 + (_SunColor * sundot * 3 + _MoonColor * pow(moondot,2) * 3) * cutoff;
				o.shd = 1 - moondot * cutoff;
				
				// curvature
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0 * _BaseTiling;
				o.uv3 = v.texcoord0;
				o.uv4 = v.texcoord1 * _WallTiling;
				
				// specular
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 worlduv2 = (worldVertex.xz - _CameraFocalPoint.xz) * -0.0055;
				o.uv2 = mul ( worlduv2, rotMat ) + float2(0.5,0.5);
				
				// vertex colors
				o.vtc = v.color;
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
				
				// color
				fixed3 outcolor = tex2D ( _BaseTex, i.uv1 ) * i.vtc.r;
				outcolor += tex2D ( _RockTex, i.uv4 ) * i.vtc.g;
				
				// baked light
				outcolor *= tex2D ( _MaskTex, i.uv3 ).ggg;
				
				// directional light
				outcolor *= 0.75 + 0.25 * smoothstep(0.75,0.85,i.shd);
				outcolor *= i.sun;
				
				// global light
				fixed4 spccolor = tex2D ( _SpecTex, i.uv2 );
				outcolor = lerp (outcolor, spccolor.rgb, spccolor.a) * _MappyAmbient;
				
				return fixed4 (outcolor.rgb,1);	
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}