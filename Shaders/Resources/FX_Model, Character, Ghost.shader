// Copyright Mechanist Games

Shader "Mechanist FX/Model/Character, Ghost"
{
	Properties
	{
		_TintColor2 ("Glow Color", Color)				= (1,1,1,1)
		_RimSize ("Glow Size", Range(0,0.3)) = 0.15
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
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
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD;
            };
			
			struct Varys
			{
				half4 pos : SV_POSITION;
				half rim : TEXCOORD1;
			};
			
			uniform fixed4 _TintColor2;
			uniform float _RimSize;
			uniform float _Pow;
			
			Varys vert ( VertInput v )
			{
				Varys o;
				
				v.vertex.xyz += _RimSize * v.normal.xyz;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				o.rim = max ( 0 , pow ( dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ), 2) * 2 );
				
				return o;
			}
			
			fixed4 frag ( Varys i) : SV_Target
			{
				fixed4 outcolor = i.rim * _TintColor2;
				return outcolor;
			}
				
			ENDCG
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha One
      		Cull Back
      		Lighting Off
			
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
						
			struct VertInput
            {
                float4 vertex		: POSITION;
                float3 normal : NORMAL;
                float2 texcoord		: TEXCOORD;
            };
			
			struct Varys
			{
				half4 pos			: SV_POSITION;
				half rim : TEXCOORD1;
			};
			
			uniform fixed4 _TintColor2;
			uniform float _RimSize;
			uniform float _Pow;
			
			Varys vert ( VertInput v )
			{
				Varys o;
				
				v.vertex.xyz += _RimSize * v.normal.xyz * 0.5;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				o.rim = max ( 0, pow ( dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ), 2) * 2 );
				
				return o;
			}
			
			fixed4 frag ( Varys i) : SV_Target
			{
				fixed4 outcolor = i.rim * _TintColor2;
				return outcolor;
			}
				
			ENDCG
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha One
      		Cull Back
      		Lighting Off
			
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
						
			struct VertInput
            {
                float4 vertex		: POSITION;
                float3 normal : NORMAL;
                float2 texcoord		: TEXCOORD;
            };
			
			struct Varys
			{
				half4 pos			: SV_POSITION;
				half rim : TEXCOORD1;
			};
			
			uniform fixed4 _TintColor2;
			uniform float _RimSize;
			uniform float _Pow;
			
			Varys vert ( VertInput v )
			{
				Varys o;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				
				o.rim = max ( 0, pow ( dot ( v.normal, normalize ( ObjSpaceViewDir ( v.vertex ) ) ), 2) * 2 );
				
				return o;
			}
			
			fixed4 frag ( Varys i) : SV_Target
			{
				fixed4 outcolor = i.rim * _TintColor2;
				return outcolor;
			}
				
			ENDCG
		}
	}
	//fallback "VertexLit"
}