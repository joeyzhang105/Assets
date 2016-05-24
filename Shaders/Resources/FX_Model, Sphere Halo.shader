// Copyright Mechanist Games

Shader "Mechanist FX/Model/Sphere Halo"
{
	Properties
	{
		_HaloColor ("Halo Color", Color) = (1,0.8,0.5,1)
		_HaloPow ("Halo Power", Range (10,1)) = 3
	}
	
	Subshader
	{
		LOD 100
	
		Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
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
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
			struct VertInput
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
            };
			
			struct vertShader
			{
				half4 pos : SV_POSITION;
				half4 glo : TEXCOORD0;
			};
			
			// properties
			uniform half4 _HaloColor;
			uniform half _HaloPow;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				// glow
				o.glo = _HaloColor * max ( 0, dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ) );
																																		
				return o;
			}
						
			half4 frag ( vertShader i ) : SV_Target {
				return i.glo;
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}