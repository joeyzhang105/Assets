// Copyright Mechanist Games

Shader "Mechanist/02 - Background, Spec"
{
	Properties
	{
		_SeamTiling ("Seam Tiling (0.25)", Float) = 0.25
		_MainTex ("Main Texture", 2D) = "black" {}
		_SeamTex ("Seam Texture", 2D) = "black" {}
		_Loc_Spc_Pow ("Specular Power (~10)", Float) = 10
		_Loc_Spc_Str ("Specular Strength (~0.5)", Float) = 0.5
	}

	Subshader
	{
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
		}
		
		Pass
		{
			
      		Cull Back
      		Fog {Mode Off}
      		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			//#pragma multi_compile LIGHTS_OFF LIGHTS_4 LIGHTS_8 LIGHTS_12
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                half4 vertex : POSITION;
			  	half4 color	: COLOR;
			  	half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv3 : TEXCOORD1;
   				fixed3 lgt : TEXCOORD2;
   				fixed sem : TEXCOORD3;
   				fixed3 spc : TEXCOORD4;
	   			fixed fog : TEXCOORD5;
			};
			
			// properties
			uniform sampler2D _MainTex;
			uniform sampler2D _SeamTex;
			uniform half _SeamTiling;
			uniform float4 _MainTex_ST;
			uniform half _Loc_Spc_Pow;
			uniform half _Loc_Spc_Str;
			
			vertShader vert ( vertInput v )
			{
				vertShader o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0 * _MainTex_ST.xy;
				o.uv3 = worldVertex.xz * _SeamTiling;
				
				// vertex lights
				o.lgt = inlineVLM_Full (v.color);
				
				// seam texture
				o.sem = v.color.a;
				
				// specular
               	float3 worldNormal = normalize ( mul ( half4 ( v.normal, 0.0 ), _World2Object ).xyz );
               	worldNormal = lerp ( worldNormal, half3(0,1,0), v.color.a);
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex) );
				o.spc = _Gbl_Spc * pow ( max ( 0, dot ( worldNormal, camDir ) ), _Loc_Spc_Pow ) * _Loc_Spc_Str;
				
				// fog
				#ifdef QUALITY_HGH
					o.fog = inlineFogVert ( worldVertex.xyz );
				#endif
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target
			{
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor = lerp ( outcolor, tex2D ( _SeamTex, i.uv3 ), i.sem );
				outcolor.rgb *= i.lgt;
				outcolor.rgb *= 1 + i.spc * (1-outcolor.a);
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.rgb = inlineFogFrag ( outcolor.rgb, i.fog );
				#endif
				
				return outcolor;		
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}