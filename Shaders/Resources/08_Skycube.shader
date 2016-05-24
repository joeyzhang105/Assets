// Copyright Mechanist Games

Shader "Mechanist/08 - Skycube"
{
	Properties
	{
		_CubeMap ("Sky Cube", CUBE) = "white"
		_FogHeightMin ("Fog Height Min", float) = 0
		_FogHeightMax ("Fog Height Max", float) = 30
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
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			#include "AutoLight.cginc"
			
			struct VertInput
            {
                float4 vertex : POSITION;
                //float3 normal : NORMAL;
                //float2 texcoord : TEXCOORD0;
		    };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float3 cam : TEXCOORD0;
				fixed fog : TEXCOORD1;
			};
			
			uniform samplerCUBE _CubeMap;
			uniform float _FogHeightMax;
			uniform float _FogHeightMin;
																			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.cam = (worldVertex - _WorldSpaceCameraPos);
				
				o.fog = smoothstep ( _FogHeightMax, _FogHeightMin, worldVertex.y ) * _FogClamp;
				
				return o;
			}
			
			fixed4 frag ( vertShader i) : SV_Target {
				fixed4 outcolor = texCUBE(_CubeMap,i.cam);
				outcolor.rgb = lerp ( outcolor.rgb, _FogColor.rgb, i.fog);
				return outcolor;
			}
			
			ENDCG
		}
	}
	
	Fallback "Diffuse"
}