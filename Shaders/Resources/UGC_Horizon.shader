// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/UGC Horizon"
{
	Properties
	{
		_UGC_Curvature ("UGC Curvature", Float) = 0.001
		_MainTex ("Horizon Texture", 2D) = "white" { }
		_SpecTex ("Detail Texture", 2D) = "white" {}
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		Pass {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
      		Cull Back
      		Fog {Mode Off}
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    float2 uv2 : TEXCOORD1;
		    };
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _SpecTex;
			
			// global properties
			uniform float3 _UGC_MapCenter;
			uniform float _UGC_Curvature;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				// curvature
				float localCurve = _UGC_Curvature;
				float3 totalDist = distance ( _UGC_MapCenter, worldVertex );
				float distanceX = totalDist.x * totalDist.x * localCurve;
				float distanceZ = totalDist.z * totalDist.z * localCurve;
				v.vertex.y -= distanceX + distanceZ;
			    
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord;
				
				// specular
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 worlduv2 = (worldVertex.xz - _UGC_MapCenter.xz) * -0.006;
				o.uv2 = mul ( worlduv2, rotMat ) + float2(0.5,0.5);
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
			    // normal calc
				fixed4 outcolor = tex2D(_MainTex, i.uv1);
				outcolor.rgb = tex2D ( _SpecTex, i.uv2 );
				
				// combine
				return outcolor;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }