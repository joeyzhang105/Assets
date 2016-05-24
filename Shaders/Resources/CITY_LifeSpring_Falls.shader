// Copyright Mechanist Games

Shader "Mechanist CITY/LifeSpring_Falls"
{
	Properties
	{
		_WaterTex ("Water Texture", 2D) = "white" {}
		_WaterColor ("Water Color", Color) = (1,1,1,1)
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
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
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vtc : TEXCOORD2;
				fixed cut : TEXCOORD3;
			};
			
			// resources
			uniform sampler2D _WaterTex;
			uniform float4 _WaterTex_ST;
			uniform samplerCUBE _Cubemap;
			
			// properties
			uniform fixed4 _WaterColor;
			
			uniform fixed _TotalBrightness;
			
			// controller stuff
			uniform float _MeshBoundsYmin;
			uniform float _MeshBoundsYmax;
			uniform float _ResourceAmount;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord0, _WaterTex ) + float2 ( _Time.x, _Time.x * 8);
				o.uv2 = o.uv1 * 0.7 + float2 ( -_Time.x, _Time.x * 7);
				
				// vertex color
				o.vtc = v.color;
				
				// cutoff
               	float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float cutFactor = ( _MeshBoundsYmax - _MeshBoundsYmin );
				float cutHeight = _MeshBoundsYmax - _ResourceAmount * cutFactor;
				o.cut = smoothstep ( cutHeight - 0.02, cutHeight + 0.02, worldVertex.y );
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed3 texcolor = tex2D ( _WaterTex, i.uv1 ) * tex2D ( _WaterTex, i.uv2 );
				fixed4 outcolor = _WaterColor;
				outcolor.rgb += texcolor.r + texcolor.b;
				outcolor.a *= texcolor.r + texcolor.b + texcolor.g;
				outcolor.a *= i.vtc.a * i.cut;
				
				return outcolor * _TotalBrightness;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}