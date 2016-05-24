// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/Space"
{
	Properties
	{
		_SpaceTex ("Space Texture", 2D) = "white" { }
		_TilesPerMeter ("Tiling", Vector) = (3,3,4,4)
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass {
      		Cull Back
      		Fog {Mode Off}
		    
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
			
			struct vertInput
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    float2 uv2 : TEXCOORD1;
		    };
			
			// resources
			uniform sampler2D _SpaceTex;
			uniform float4 _TilesPerMeter;
			uniform float _Curvature;
			uniform float3 _CameraFocalPoint;
			
			// global
			uniform fixed3 _SpaceLight;
			uniform fixed3 _SpaceDark;
			uniform float _CloudSpeed;
			
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
			    
				// pos and uv tex coord
			    o.pos = mul ( UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord * _TilesPerMeter.xy + _WorldSpaceCameraPos.xz * 0.005 + float2(_Time.x * -0.1, _Time.x * 0.02) * _CloudSpeed;
				o.uv2 = v.texcoord * _TilesPerMeter.zw + _WorldSpaceCameraPos.xz * 0.0025 + float2(_Time.x * -0.2, _Time.x * 0.03) * _CloudSpeed;
				
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target {
				
			    // outcolor
				fixed3 outcolor = tex2D ( _SpaceTex, i.uv1 );
				outcolor = lerp ( _SpaceDark, _SpaceLight, 0.4 * ( outcolor.r + outcolor.g + outcolor.b));
				
				outcolor += tex2D ( _SpaceTex, i.uv2 ).a;
				
				// combine
				return fixed4(outcolor, 1 );
			}
			ENDCG
		}
	}
	//Fallback "Diffuse"
 }