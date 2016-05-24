// Copyright Mechanist Games

Shader "Mechanist MAP/Glow"
{
	Properties
	{
		_MainTex ("Base Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (1,1,1,1)
	}
		
	Subshader
	{
		
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
      		Cull Back
      		Zwrite Off
      		Ztest Off
      		Blend SrcAlpha One
      		Fog {Mode Off}
      		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertexInput
            {
                half4 vertex : POSITION;
                half2 texcoord	: TEXCOORD0;
                fixed4 color : COLOR;
            };
			
			struct vertShader
			{
				// basics
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				fixed4 color : COLOR;
			};
			
			// assets
			uniform sampler2D _MainTex;
			
			// local properties
			uniform fixed3 _TintColor;
			
			// global properties
			uniform float3 _CameraFocalPoint;
			uniform float _Curvature;
			
			vertShader vert ( vertexInput v )
			{
				vertShader o;
               	half4 worldVertex = mul ( _Object2World, v.vertex );
               	float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				
				// curvature
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				worldVertex.y -= distanceX + distanceZ;
				v.vertex = mul(_World2Object, worldVertex);
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord;
				o.color = v.color;
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
				// textures
				fixed3 outcolor = tex2D ( _MainTex, i.uv1 ) * i.color;// * _TintColor;
				
				return fixed4 (outcolor.rgb,1);
			}
				
			ENDCG
		}
	}
	//FallBack "VertexLit"
}