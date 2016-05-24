// Copyright Mechanist Games

Shader "Mechanist CITY/Liquid Metal"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormTex ("Normals", 2D) = "white" {}
		_CubeMap ("Cube Map", CUBE) = "white" {}
		_Pour ("Pour Amount", Range(-0.1,1.1)) = 0.5
		_ActiveColor0 ("Active Metal Color Dark",Color) = (1,1,1,1)
		_ActiveColor1 ("Active Metal Color Bright",Color) = (1,1,1,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent"
			"LightMode" = "Always"
		}
		
		Pass
		{
      		Cull Back
      		Blend SrcAlpha OneMinusSrcAlpha
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				//float3 cam : TEXCOORD3;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _NormTex;
			uniform samplerCUBE _CubeMap;
			uniform float4 _MainTex_ST;
			
			// local properties
			uniform fixed3 _ActiveColor0;
			uniform fixed3 _ActiveColor1;
			uniform fixed _Pour;
			
			vertShader vert ( appdata_full v )
			{
				vertShader o;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord, _MainTex );
				o.uv2 = v.texcoord * 0.9;
				o.uv3 = v.texcoord + float2(0,_Time.x);
				
				//o.cam = normalize ( WorldSpaceViewDir (v.vertex) );
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : COLOR {
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				
				// normals
				fixed3 normals = normalize (tex2D ( _NormTex, i.uv2 ) - tex2D ( _NormTex, i.uv3 ));
				
				// pouring
				outcolor.a = step(0, _Pour - outcolor.r + normals.r * 0.05);
				
				// molten effect
				fixed3 cubemap = texCUBE( _CubeMap, normalize ( fixed3( normals.r, 0.5, normals.g ) ) );
				outcolor.rgb = lerp (_ActiveColor0,_ActiveColor1,cubemap);
				
				// energy effect
				fixed smoother = smoothstep (-0.2, 0.2, normals.r);
				outcolor.rgb += smoother * (1-smoother) * 2;
				
				// specular
				//outcolor.rgb += pow(dot(i.cam, normals),4);
				
				return outcolor;
			}
			
		ENDCG
		}
	}
	FallBack "VertexLit"
}