// Copyright Mechanist Games

Shader "Mechanist/08 - Skyfloor"
{
	Properties
	{
		_CubeMap ("Sky Cube", CUBE) = "white"
		_NormTex ("Normal Texture", 2D) = "white"
	}

	Subshader
	{	
		Tags {
			"Queue" = "Geometry"
			"LightMode" = "ForwardBase"
		}
		
		Pass
		{
      	 	Cull Back
      		Fog {Mode Off}
      		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
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
				float3 cam : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				fixed4 vtc : TEXCOORD2;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(7)
				#endif
			};
			
			uniform samplerCUBE _CubeMap;
			uniform sampler2D _NormTex;
			uniform float4 _NormTex_ST;
																			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.cam = (worldVertex - _WorldSpaceCameraPos);
				o.uv1 = v.texcoord.xy * _NormTex_ST.xy;
				o.vtc = v.color;
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i) : SV_Target {
				fixed4 outcolor = tex2D ( _NormTex, i.uv1 );
				fixed3 camDir = i.cam + outcolor.rgb * i.vtc.a;
				fixed3 skycolor = texCUBE(_CubeMap, camDir);
				
				#if !defined (SHADOWS_OFF)
					outcolor.rgb *= _Gbl_Amb + _Gbl_Lgt * SHADOW_ATTENUATION(i);
				#endif
				
				outcolor.rgb = lerp ( skycolor, outcolor.rgb, i.vtc.a * 0.5 * (1-outcolor.a * 0.5));
				
				return outcolor;
			}
			
			ENDCG
		}
	}
	
	Fallback "Diffuse"
}