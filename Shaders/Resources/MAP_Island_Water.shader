// Copyright Mechanist Games

Shader "Mechanist MAP/Island Water"
{
	Properties
	{
		_BaseTiling ("Base Tiling", Float) = 1
		_TilesPerMeter ("Tiles Per Meter (XY,ZW)", Vector) = (0.01,0.01,0.01,0.01)
		_NormalSpeed ("Ripples: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_BaseTex ("Base Texture", 2D) = "white" {}
		_MaskTex ("Water Texture", 2D) = "white" {}
		_NormTex ("Normal Texture", 2D) = "white" {}
		_SpecTex ("Specular Texture", 2D) = "white" {}
	}

	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		Pass
		{
      		Cull Back
      		ZWrite Off
      		Blend SrcAlpha OneMinusSrcAlpha
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
                half4 vertex : POSITION;
                half4 color : COLOR;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				float2 uv4 : TEXCOORD3;
				float2 uv5 : TEXCOORD4;
				float4 vtc : TEXCOORD5;
			};
			
			// resources
			uniform sampler2D _BaseTex;
			uniform sampler2D _MaskTex;
			uniform sampler2D _NormTex;
			uniform sampler2D _SpecTex;
			
			// local properties
			uniform float _BaseTiling;
			uniform float4 _TilesPerMeter;
			uniform float4 _NormalSpeed;
			
			// global properties
			uniform float3 _CameraFocalPoint;
			uniform float _Curvature;
			uniform fixed3 _MappyAmbient;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV1 = worldVertex.xz * _TilesPerMeter.xy;
				float2 worldUV2 = worldVertex.xz * _TilesPerMeter.zw;
				
				// curvature
				float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = worldUV1 + float2 ( _Time.xx * _NormalSpeed.xy);
				o.uv2 = worldUV2 + float2 ( _Time.xx * _NormalSpeed.zw);
				o.uv3 = v.texcoord0;
				o.uv4 = v.texcoord0 * _BaseTiling;
				
				// specular
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 worlduv2 = (worldVertex.xz - _CameraFocalPoint.xz) * -0.0055;
				o.uv5 = mul ( worlduv2, rotMat ) + float2(0.5,0.5);
				
				o.vtc = v.color;
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
			    // normals
				fixed3 masktex = tex2D(_MaskTex, i.uv3);
				fixed3 texnorms = (tex2D(_NormTex, i.uv1) - tex2D(_NormTex, i.uv2));
				fixed2 norms = texnorms.rg * 0.05;
				
				// color
				fixed3 outcolor = tex2D ( _BaseTex, i.uv4 + norms * masktex.rr );
				
				// baked lighting
				outcolor *= masktex.ggg;
				
				// lighting
				fixed4 spccolor = tex2D ( _SpecTex, i.uv5 );
				outcolor = lerp (outcolor, spccolor.rgb, spccolor.a) * _MappyAmbient;
				
				return fixed4 (outcolor.rgb,masktex.b * i.vtc.a);	
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}