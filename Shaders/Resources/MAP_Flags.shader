// Copyright Mechanist Games

Shader "Mechanist MAP/Flags"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Curvature ("Curvature", Float) = 0.00015
	}

	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
      		Cull Off
      		Fog {Mode Off}
      		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
			struct VertInput
            {
                half4 vertex : POSITION;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
			};
			
			uniform sampler2D _MainTex;
			uniform float _Curvature;
			uniform float3 _CameraFocalPoint;;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				// curvature
				float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
			    
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
				// texture
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 );
				
				return fixed4 (outcolor,1);	
			}
			
			ENDCG
		}
	}
	//FallBack "Diffuse"
}