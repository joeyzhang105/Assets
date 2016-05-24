// Copyright Mechanist Games

Shader "Mechanist/10 - Global Color Halo"
{
	Properties
	{
		_SwellSpd ("Swell Speed", Float ) = 1
		_SwellFlu ("Swell Flux", Float ) = 0.2
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Transparent+1"
			//"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha One
      		Cull Back
      		Lighting Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float4 glo : TEXCOORD0;
	   			fixed fog : TEXCOORD1;
			};
			
			// properties
			uniform float _SwellSpd;
			uniform float _SwellFlu;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				// glow
				o.glo = float4(_Gbl_Pnt,0.5) * pow ( max ( 0, dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ) ), 2 + 2 * sin ( _SwellSpd * _Time.z ) * _SwellFlu);
				
				// fog
				#ifdef QUALITY_HGH
       				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
					float fogDistance = 0.75 * length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
					fixed fogAmount = clamp ( fogDistance / _FogDistMax, 0, _FogClamp );
					o.fog = fogAmount;
				#endif				
																											
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
			
				fixed4 outcolor = i.glo;
				
				// fog
				#ifdef QUALITY_HGH
					outcolor.a *= 1 - i.fog;
				#endif
				
				return outcolor;
			}
			
		ENDCG
		}
	}
	//FallBack "Diffuse"
}