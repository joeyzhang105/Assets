// Copyright Mechanist Games

Shader "Mechanist CITY/Upgrade"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DisTex ("Water Texture", 2D) = "white" {}
		_Progress ("Building Progress", Range(0,1)) = 0.5
		//[HideInInspector] _MeshBoundsYmin ("Building Height, Start", Float) = 0
		//[HideInInspector] _MeshBoundsYmax ("Building Height, Finish", Float) = 2
		[HideInInspector] _UpgradeColor ("Construction Color", Color ) = (1,1,1,0)
		_UpColor ("Upgrade Color", Color ) = (0.5,0.5,1,0)
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
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float spc : TEXCOORD1;
				float cut : TEXCOORD2;
				float3 glo : TEXCOORD3;
				float2 uv2 : TEXCOORD4;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _DisTex;
			uniform float4 _DisTex_ST;
			
			// properties
			uniform float _MeshBoundsYmin;
			uniform float _MeshBoundsYmax;
			uniform float _Progress;
			uniform fixed3 _UpgradeColor;
			uniform fixed3 _UpColor;
			
			uniform fixed _TotalBrightness;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				
				// diffuse reflection
               	float3 worldNormal = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				float3 camDir = normalize ( WorldSpaceViewDir (v.vertex)  + _WorldSpaceLightPos0);
				o.spc = pow ( abs ( dot ( worldNormal, camDir ) ), 15 ) * 2;
				
				// cutoff
               	float3 cutVertex = mul ( _Object2World, v.vertex ).xyz;
               	cutVertex.y += 0.008 * sin ( (cutVertex.x + cutVertex.z) * 200 + _Time.w);
				float cutFactor = ( _MeshBoundsYmax - _MeshBoundsYmin );
				float cutHeight = _MeshBoundsYmin + _Progress * cutFactor;
				o.cut = smoothstep ( cutHeight + 0.1, cutHeight - 0.1, cutVertex.y );
				o.glo = pow ( o.cut * ( 1 - o.cut), 4) * 100 * _UpColor;
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = v.texcoord0;
				o.uv2 = v.vertex.xy * 2 - float2( 0, _Time.x * 7.5);
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				
				// specular
				fixed4 texcolor = tex2D ( _MainTex, i.uv1 );
				fixed3 outcolor = texcolor.rgb + i.spc * texcolor.aaa;
				
				// greyout unfinished part
				fixed greyout = 0.333 * (outcolor.r + outcolor.g + outcolor.b);
				fixed sstep = smoothstep( 0.4, 0.6, i.cut.r * ( 0.666 + greyout * 0.666 ) );
				outcolor = lerp ( greyout * _UpColor, outcolor, step ( 0.5, sstep ).rrr );
				
				// add progress line
				outcolor += i.glo + sstep * ( 1 - sstep) * 10;
				
				// pulse wave
				fixed upLine = tex2D ( _DisTex, i.uv2 + float2 ( 0, greyout * 0.25 ) );
				outcolor += ( 1 - sstep ) * upLine;
				
				return fixed4(outcolor * _TotalBrightness,1);
			}
			
		ENDCG
		}
	}
	FallBack "Diffuse"
}