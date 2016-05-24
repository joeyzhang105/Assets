// Copyright Mechanist Games

Shader "Mechanist CITY/LifeSpring_Water"
{
	Properties
	{
		_MainTex ("Under Texture", 2D) = "white" {}
		_WaterTex ("Water Texture", 2D) = "white" {}
		_WaterColor ("Water Color", Color) = (1,1,1,1)
		_SpecuColor ("Specular Color", Color) = (1,1,1,1)
		_DistortAmount ("Refraction", Float) = 0.005
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
		}
		
		Pass
		{
      		Cull Off
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
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				float3 cam : TEXCOORD3;
				fixed cut : TEXCOORD4;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _WaterTex;
			uniform float4 _MainTex_ST;
			uniform float4 _WaterTex_ST;
			
			// properties
			uniform fixed3 _WaterColor;
			uniform fixed3 _SpecuColor;
			uniform float _DistortAmount;
			
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
				o.uv1 = TRANSFORM_TEX ( v.texcoord1, _MainTex );
				
				// diffuse reflection
               	float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				o.cam = normalize ( WorldSpaceViewDir (v.vertex) );
				
				o.uv2 = TRANSFORM_TEX ( v.texcoord0, _WaterTex ) + _Time.x * 0.7;
				o.uv3 = o.uv2 * 0.8 - _Time.x;
				
				// cutoff
				float cutFactor = ( _MeshBoundsYmax - _MeshBoundsYmin );
				float cutHeight = _MeshBoundsYmax - _ResourceAmount * cutFactor;
				o.cut = smoothstep ( cutHeight + 0.02, cutHeight - 0.02, worldVertex.y );
				
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
			
				fixed3 waternrm = tex2D ( _WaterTex, i.uv2 ) - tex2D ( _WaterTex, i.uv3 );
				waternrm = normalize(fixed3(waternrm.r,0.333,waternrm.g)) * (1-i.cut);
				fixed3 texcolor = tex2D ( _MainTex, i.uv1 + waternrm.rb * _DistortAmount );
				
				// specular
				fixed3 outcolor = texcolor * ( 0.5 + _WaterColor.rgb) + 0.333 * waternrm.rrr * waternrm.bbb;
				outcolor += pow ( max ( 0, dot ( waternrm, i.cam ) ), 20 ) * _SpecuColor.rgb;
				
				// cut
				outcolor = lerp (outcolor, texcolor, i.cut);
				
				return fixed4(outcolor * _TotalBrightness,1);
			}
			
		ENDCG
		}
	}
	//FallBack "VertexLit"
}