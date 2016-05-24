// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/Additive"
{
	Properties
	{
		_Extrude ("Normal Extrusion", Range(0,1)) = 0.0
		_Scale ("UV Scaling", Range(1,2)) = 0.0
		_CurveDir ("World Curve Vector", Vector) = (0,-1,0,0)
		_TintColor ("Tint Color", Color) = (1,1,1,1)
		_GlowAmt ("Glow Brightness", Float) = 0.2
		_GlowSpd ("Glow Speed", Float) = 1
		_MainTex ("Main RGB Texture", 2D) = "white" { }
	}
	
	SubShader {
	
		LOD 100
		
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
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
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    fixed4 glo : TEXCOORD1;
		    };
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			// local properties
			uniform float3 _CurveDir;
			uniform fixed4 _TintColor;			
			uniform float _Extrude;		
			uniform float _Scale;
			uniform float _GlowAmt;
			uniform float _GlowSpd;
			
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
				v.vertex.xyz += _CurveDir * (distanceX + distanceZ);
				
				// extrusion
				v.vertex.xyz += v.normal.xyz * _Extrude;
				
				// pos
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			    
			    // UV calculation
				o.uv1 = ((v.texcoord0 - 0.5) * _MainTex_ST.xy + _MainTex_ST.zw ) / _Scale + 0.5;
				
				// glow
				o.glo = 1 + sin(_Time.z * _GlowSpd) * _GlowAmt;
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target
			{	
			    // base
			    fixed4 outcolor = tex2D(_MainTex, i.uv1) * _TintColor * i.glo;
			    outcolor.a = 1;
			    
				// return
				return outcolor;
			}
			ENDCG
		}
	}
	//Fallback "VertexLit"
 }