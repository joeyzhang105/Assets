// Copyright Mechanist Games

Shader "Mechanist CITY/Skycube"
{
	Properties
	{
		_CubeMap ("Sky Cube", CUBE) = "white"
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
			
			struct VertInput
            {
                float4 vertex : POSITION;
		    };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float3 cam : TEXCOORD0;
			};
			
			uniform samplerCUBE _CubeMap;
			
			uniform fixed _TotalBrightness;
																			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.cam = (worldVertex - _WorldSpaceCameraPos);
				return o;
			}
			
			fixed4 frag ( vertShader i) : SV_Target {
			fixed4 outcolor = texCUBE(_CubeMap,i.cam) * _TotalBrightness;
				return outcolor;
			}
			
			ENDCG
		}
	}
	
	Fallback "Diffuse"
}