// Upgrade NOTE: replaced 'defined SHADOWS_OFF' with 'defined (SHADOWS_OFF)'

// Copyright Mechanist Games

Shader "Mechanist GUI/GUI, Shadow"
{
	Subshader
	{
		LOD 100
	
		Tags {
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		Pass
		{
      		Cull Back
      		Blend Zero SrcColor
      		Fog {Mode Off}
      		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
			#if !defined (SHADOWS_OFF)
				#include "AutoLight.cginc"
			#endif
			
			struct VertInput
            {
                half4 vertex : POSITION;
            };
			
			struct Varys
			{
				half4 pos : SV_POSITION;
				
				#if !defined (SHADOWS_OFF)
		   	    	SHADOW_COORDS(3)
				#endif
			};
			
			uniform sampler2D _MainTex;
			
			Varys vert ( VertInput v )
			{
				Varys o;
               	half3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				#if !defined (SHADOWS_OFF)
	      			TRANSFER_SHADOW(o);
				#endif
				
				return o;
			}
			
			fixed4 frag ( Varys i ) : SV_Target {
			
				fixed3 outcolor = (1,1,1);
				#if !defined (SHADOWS_OFF)
					outcolor *= SHADOW_ATTENUATION(i);
				#endif
				
				return fixed4 (outcolor,1);	
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}