// Copyright Mechanist Games

Shader "Mechanist MAP/Plants"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) = "white" {}
		
		_WindSpd ("Wind Speed (25)", Float ) = 25
		_WindAmt ("Wind Frequency", Range(0.2,1.8) ) = 1
		_WindStr ("Wind Strength", Range(0,0.2) ) = 0.1
		
		_TumbSpd ("Tumbling Speed (100)", Float ) = 200
		_TumbAmt ("Tumbling Frequency", Range(10,50) ) = 30
		_TumbStr ("Tumbling Strength", Range(0,0.2) ) = 0.1
		
		_SpecTex ("Spec Texture", 2D) = "white" {}
		
		//_TransparencyLM ("Lightmap Transparency", 2D ) = "white"{}
	}
	
	Subshader
	{
		LOD 100
		
		Tags {
			"Queue" = "Transparent"
			//"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass
		{
			ZWrite Off
      	 	Blend SrcAlpha OneMinusSrcAlpha
      		Cull Off
      		Lighting Off
      		Fog {Mode Off}
			
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile BEND_OFF BEND_3 BEND_6 BEND_9
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile QUALITY_LOW QUALITY_MED QUALITY_HGH
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			#include "MechanistCG.cginc"
						
			struct VertInput
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half4 color : COLOR;
                half2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				half4 pos	: SV_POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half3 lgt : TEXCOORD2;
				fixed3 sun : TEXCOORD3;
				fixed shd : TEXCOORD4;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _SpecTex;
			
			// local properties
			uniform float _WindSpd;
			uniform float _WindAmt;
			uniform float _WindStr;
			uniform float _TumbSpd;
			uniform float _TumbAmt;
			uniform float _TumbStr;
			
			// global properties
			uniform float3 _CameraFocalPoint;
			uniform float _Curvature;
			uniform fixed3 _SunColor;
			uniform fixed3 _MoonColor;
			uniform fixed3 _MappyAmbient;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex );;
               	float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				
				// curvature
				float distanceX = totalDist.x * totalDist.x * _Curvature;
				float distanceZ = totalDist.z * totalDist.z * _Curvature;
				v.vertex.y -= distanceX + distanceZ;
				
				// wind bending
				#ifdef QUALITY_HGH
					float Coef1 = _WindSpd * _Time.x;
					float2 grassMove = float2 (sin(Coef1 + (worldVertex.x * _WindAmt)), cos(Coef1 + (worldVertex.z * _WindAmt))) * _WindStr;
               	
					// leaf tumbling
					float Coef2 = _TumbSpd * _Time.x;
					float worldVertexSum = worldVertex.x + worldVertex.z;
					float tumbling = sin(Coef2 + _TumbAmt * worldVertexSum) * _TumbStr;
				
					// apply animations
					v.vertex.xyz += float3(grassMove.x, tumbling, grassMove.y) * v.color.a;
					
					// vertex lights
					half bendCol = tumbling + grassMove.x + grassMove.y;
					bendCol = bendCol * bendCol;
					o.lgt = 1 + bendCol.xxx;
				#else
					o.lgt = 1;
				#endif
				
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex );
				o.uv1 = v.texcoord0;
               	
				// specular
				float dirSin = sin(-_WorldSpaceLightPos0.x);
				float dirCos = sin(-_WorldSpaceLightPos0.z);
				float2x2 rotMat = float2x2 ( float2(dirCos, dirSin), float2(-dirSin, dirCos)) * float2x2(float2(0.5,0.5),float2(0.5,0.5)) + float2x2(float2(0.5,0.5),float2(0.5,0.5));
				rotMat = rotMat * float2x2(float2(2,2),float2(2,2)) - float2x2(float2(1,1),float2(1,1));
				float2 worlduv2 = (worldVertex.xz - _CameraFocalPoint.xz) * -0.0055;
				o.uv2 = mul ( worlduv2, rotMat ) + float2(0.5,0.5);
				
               	// lighting
               	float3 worldNormal = normalize ( mul ( float4 ( lerp(v.normal,float3(0,0.9,0),v.color.r), 0.0 ), _World2Object ).xyz );
               	float3 worldMoonLgt = float3(-_WorldSpaceLightPos0.x,_WorldSpaceLightPos0.y,-_WorldSpaceLightPos0.z);
				float sundot = pow ( max ( 0, dot(_WorldSpaceLightPos0, worldNormal) ), 3);
				float moondot = max ( 0, dot( worldMoonLgt, worldNormal) );
				float cutoff = clamp(v.vertex.y, 0, 1);
				o.sun = 1 + (_SunColor * sundot * 2 + _MoonColor * pow(moondot,2) * 2) * cutoff;
				o.shd = 1 - moondot * cutoff;
				
				
				return o;
			}
			
			fixed4 frag ( vertShader i ) : SV_Target {
			
				fixed4 outcolor = tex2D ( _MainTex, i.uv1 );
				outcolor.rgb *= i.lgt;
				outcolor.rgb *= 0.75 + 0.25 * smoothstep(0.75,0.85,i.shd);
				outcolor.rgb *= i.sun;
				
				// global light
				fixed4 spccolor = tex2D ( _SpecTex, i.uv2 );
				outcolor.rgb = lerp (outcolor, spccolor.rgb, spccolor.a) * _MappyAmbient;
				
				return outcolor;
			}
			ENDCG
		}
	}
	Fallback "VertexLit"
}