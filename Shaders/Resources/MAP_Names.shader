// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/Names"
{
	Properties
	{
		_MainTex ("Main RGB Texture", 2D) = "white" { }
	}
	
	SubShader {
	
		LOD 100
		
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass {
			Blend SrcAlpha One
			ZWrite Off
      		Cull Back
      		Fog {Mode Off}
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    fixed fade : TEXCOORD1;
		    };
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			// global properties
			uniform float3 _CameraFocalPoint;
			uniform float _Curvature;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				// curvature
				float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
				
				// pos
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			    
			    // UV calculation
				o.uv1 = (v.texcoord0 - float2(0.5,0)) * _MainTex_ST.xy + float2(0.5,0) + _MainTex_ST.zw;
				
				// fade
				float focalDist = distance( _WorldSpaceCameraPos, _CameraFocalPoint);
				o.fade = smoothstep ( 25, 50, focalDist );
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target
			{	
			    // base
			    fixed3 outcolor = 0.25 * tex2D(_MainTex, i.uv1);
			    fixed outalpha = i.fade;
			    
				// return
				return fixed4(outcolor, outalpha);
			}
			ENDCG
		}
	}
	//Fallback "VertexLit"
 }