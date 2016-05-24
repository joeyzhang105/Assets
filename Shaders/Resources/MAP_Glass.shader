// Copyright Mechanist Games

Shader "Mechanist MAP/Glass"
{
	Properties
	{
		_ComicTex ("Comic Texture", 2D) = "white" {}
		_CubeMap ("Cube Map", CUBE) = "white" {}
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
		}
		
		Pass
		{
			//ZWrite Off
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		Cull Back
      		Lighting Off
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
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half3 cam : TEXCOORD2;
			};
			
			// resources
			uniform sampler2D _ComicTex;
			uniform samplerCUBE _CubeMap;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
               	half3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				o.cam = reflect(normalize(worldVertex - _WorldSpaceCameraPos), worldNormal);
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed3 cubecolor = texCUBE(_CubeMap, i.cam);
				fixed3 comiccolor = tex2D (_ComicTex, i.uv1);
				fixed3 outcolor = cubecolor + comiccolor;
				outcolor *= 0.5;
				
				return fixed4(outcolor, 0.666);
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}