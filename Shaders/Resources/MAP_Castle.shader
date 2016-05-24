// Copyright Mechanist Games

Shader "Mechanist MAP/Castle"
{
	Properties
	{
		_UGC_Curvature ("UGC Curvature", Float) = 0.001
		_BaseTex ("Color Texture", 2D) = "white" {}
		_SpecTex ("Spec Texture", 2D) = "white" {}
		_CastleSpec ("Sun Color", Color) = (1,1,1,1)
		_CastleFog ("Fog Color", Color) = (0.4,0.6,0.8,1)
		_FogUpper ("Fog Upper Limit", Float) = 24
		_FogLower ("Fog Lower Limit", Float) = 17
	}
	

	Subshader
	{
	
		Tags {
			"Queue" = "Geometry"
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
			
			#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash
			
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
				fixed shd : TEXCOORD2;
				fixed col : TEXCOORD3;
				fixed3 spc : TEXCOORD4;
				fixed fog : TEXCOORD5;
			};
			
			// resources
			uniform sampler2D _BaseTex;
			uniform sampler2D _SpecTex;
			
			// local properties
			uniform fixed3 _CastleSpec;
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
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 cameraDir = normalize(_WorldSpaceCameraPos - worldVertex);
				
				// fog
				o.fog = smoothstep ( _FogUpper, _FogLower, worldVertex.y);
				
				// lighting
				o.shd = max(0, dot(_WorldSpaceLightPos0, worldNormal));
				o.spc = _CastleSpec * pow( max(0, dot(cameraDir, worldNormal)), 5) * 3;
				
				// curvature
               	float3 totalDist = distance ( _UGC_MapCenter, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _UGC_Curvature;
				float distanceZ = totalDist.z * totalDist.z * _UGC_Curvature;
				v.vertex.y -= distanceX + distanceZ;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				
				// sun glow
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 cloudUV = (worldVertex.xz - _UGC_MapCenter.xz) * fixed2(-0.007, -0.007);
				o.uv2 = mul ( cloudUV, rotMat ) + float2(0.5,0.5);
				
				// color
				o.col = smoothstep ( 0, 150, distance( _UGC_MapCenter , worldVertex ));
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
				
				// color
				fixed4 outcolor = tex2D ( _BaseTex, i.uv1 );
				
				// directional light
				outcolor.rgb *= 0.333 + 0.666 * i.shd;
				
				// specular
				outcolor.rgb += i.spc * outcolor.a;
				
				// fog
				outcolor.rgb = lerp(outcolor, _CastleFog, i.fog);
				
				// global light
				fixed4 spccolor = tex2D ( _SpecTex, i.uv2 );
				outcolor = lerp (outcolor, spccolor, i.col);
				
				return outcolor;	
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}