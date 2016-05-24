// Copyright Mechanist Games

Shader "Mechanist MAP/Line"
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1,1,1,1)
		_ProgressColor ("Glow Color", Color) = (1,1,1,1)
		_ArrowColor ("Arrow Color", Color) = (1,1,1,1)
		_PulseColor ("Pulse Color", Color) = (1,1,1,1)
		_ArrowGlowSpeed ("Pulse Glow Speed", Float) = 1
		_ArrowMoveSpeed ("Pulse Move Speed", Float) = 1
		_Stretch ("Arrow Stretch (~20)", Float ) = 20
		_ArrowStretch ("Pulse Stretch (~1)", Float ) = 1
		_Thickness ("Arrow Thickness", Range (2,1) ) = 1
		_LinePrg ("Line Progress Texture", 2D) = "white" {}
		_LineFwd ("Arrow Texture", 2D) = "white" {}
		_LineShow ("Total Alpha (0 - 1)", Range(0,1) ) = 0
		_ProgressShow ("Player Distance (0 - 100)", Float ) = 0
	}

	Subshader
	{
	
		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
      		Cull Back
      		ZWrite Off
      		Blend SrcAlpha One
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
                float2 texcoord : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				fixed fad : TEXCOORD3;
			};
			
			// resources
			uniform sampler2D _LinePrg;
			uniform sampler2D _LineFwd;
			uniform sampler2D _LineDot;
			
			// local properties
			uniform float _LineShow;
			uniform float _ProgressShow;
			uniform fixed3 _LineColor;
			uniform fixed3 _ProgressColor;
			uniform fixed3 _ArrowColor;
			uniform fixed3 _PulseColor;
			uniform float _ArrowGlowSpeed;
			uniform float _ArrowMoveSpeed;
			uniform float _ArrowStretch;
			uniform float _Stretch;
			uniform float _Thickness;
			
			// global properties
			uniform float _Curvature;
			uniform float3 _CameraFocalPoint;;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				
				// curvature
				float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
			    
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = float2 ( v.texcoord.x * _Stretch - _ProgressShow * (_Stretch/100), v.texcoord.y );
				o.uv1 = (o.uv1 - float2(0.5,0.5)) * (1 + 0.1 * sin(_Time.w)) * float2 ( _ArrowStretch, _Thickness ) + float2(0.5,0.5);
				o.uv2 = v.texcoord * float2 ( _ArrowStretch, _Thickness ) - float2 ( _Time.w * _ArrowMoveSpeed, 0 );
				
				// fade out
				o.fad = smoothstep ( 45,20, distance ( _WorldSpaceCameraPos + float3(0,0,20), worldVertex ) );
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			    
				// line
				fixed3 texcolor = tex2D ( _LinePrg, i.uv1 );
				
				// progress
				fixed3 outcolor = _LineColor * texcolor.r + _ProgressColor * texcolor.g + _ArrowColor * texcolor.b;
				
				outcolor += tex2D ( _LineFwd, i.uv2 ) * (texcolor.r + texcolor.g + texcolor.b) * _PulseColor;
				outcolor *= _LineShow;
				
				return fixed4(outcolor,i.fad);	
			}
			
			ENDCG
		}
	}
	//FallBack "Diffuse"
}