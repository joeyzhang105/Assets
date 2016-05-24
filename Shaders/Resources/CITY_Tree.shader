// Copyright Mechanist Games

Shader "Mechanist CITY/Tree"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			ZWrite Off
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		Cull Off
      		Lighting Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				fixed zFx : TEXCOORD1;
				fixed spc : TEXCOORD2;
			};
			
			// resources
			uniform sampler2D _MainTex;
			
			uniform fixed _TotalBrightness;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// ripple
				float phaseOffset = 25 * (v.vertex.x + v.vertex.z);
				float waveX = sin ( phaseOffset + _Time.z ) * 0.007 * v.color.a;
				float waveZ = cos ( phaseOffset + _Time.z ) * 0.007 * v.color.a;
				v.vertex.x += waveX;				
				v.vertex.z += waveZ;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord;
				o.zFx = smoothstep ( 0.4, 0.7, abs ( dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ) ) );
				
				// diffuse reflection
               	float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				o.spc = 0.25 + 0.75 * pow ( max ( 0, dot ( worldNormal, normalize ( WorldSpaceViewDir (v.vertex) ) ) ), 2 );
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				outcolor.rgb += i.spc * outcolor.rgb;
				outcolor.rgb *= _TotalBrightness;
				outcolor.a *= i.zFx;
				
				return outcolor;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}