// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist MAP/Clouds"
{
	Properties
	{
		_TilesPerMeter1 ("Alpha Tiling, XY, XY", Vector) = (1,1,1,1)
		_TilesPerMeter2 ("Texture Tiling, XY, XY", Vector) = (1,1,1,1)
		//_CloudyDarkColor ("Cloud Dark Color", Color ) = (1,1,1,1)
		//_CloudyLightColor ("Cloud Light Color", Color ) = (1,1,1,1)
		_Amount ("Cloud Amount (1.0)", Float) = 1
		_Soft ("Cloud Softness (0.3)", Float) = 0.25
		_WindSpeed ("Alpha: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		_TexSpeed ("Texture: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_CloudAlpha ("Cloud Alpha", 2D) = "white" { }
		_CloudTex ("Cloud Texture", 2D) = "white" { }
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Transparent+1"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
			"ForceNoShadowCasting" = "True"
		}
		
		Pass {
		
      		Cull Back
      		ZWrite Off
      		Blend SrcAlpha OneMinusSrcAlpha
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
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };
            
			struct vertShader {
		    	float4 pos : SV_POSITION;
			    float2 uv1 : TEXCOORD0;
			    float2 uv2 : TEXCOORD1;
			    float2 uv3 : TEXCOORD2;
			    float2 uv4 : TEXCOORD3;
			    float2 amt : TEXCOORD4;
			    fixed4 vtc : TEXCOORD5;
		    };
			
			// resources
			uniform sampler2D _CloudAlpha;
			uniform sampler2D _CloudTex;
			uniform sampler2D _Airship;
			uniform sampler2D _Specular;
			
			// properties
			uniform float _ShadowSize;
			uniform float4 _TilesPerMeter1;
			uniform float4 _TilesPerMeter2;
			uniform float4 _WindSpeed;
			uniform float4 _TexSpeed;
			uniform fixed3 _SunColor;
			uniform fixed _Amount;
			uniform float _ShadowOffset;
			
			// global
			uniform float _Curvature;
			uniform float3 _CameraFocalPoint;
			uniform fixed4 _CloudyLightColor;
			uniform fixed4 _CloudyDarkColor;
			uniform float _CloudSpeed;
			uniform float _CloudSize;
			uniform fixed _CloudSoft;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
				float2 worldUV = worldVertex.xz;
				
				// curvature
				float cloudCurve = _Curvature * 0.975;
				float3 totalDist = distance ( _CameraFocalPoint, worldVertex );
				float distanceX = totalDist.x * totalDist.x * cloudCurve;
				float distanceZ = totalDist.z * totalDist.z * cloudCurve;
				v.vertex.y -= distanceX + distanceZ;
			    
			    // UV calculation
				o.uv1 = worldUV * _TilesPerMeter1.xy * _CloudSize + float2 ( _Time.xx * _WindSpeed.xy) * _CloudSpeed;
				o.uv2 = worldUV * _TilesPerMeter1.zw * _CloudSize + float2 ( _Time.xx * _WindSpeed.zw) * _CloudSpeed;
				o.uv3 = worldUV * _TilesPerMeter2.xy * _CloudSize + float2 ( _Time.xx * _TexSpeed.xy ) * _CloudSpeed;
				o.uv4 = worldUV * _TilesPerMeter2.zw * _CloudSize + float2 ( _Time.xx * _TexSpeed.zw ) * _CloudSpeed;
				
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			    
			    // vertex color
			    o.vtc = v.color;
			    
			    // amount
			    //float cloudAmount = 0.01 * _Amount + smoothstep ( 50,0, distance ( _WorldSpaceCameraPos + float3(0,0,20), worldVertex ) );
			    o.amt = float2 ( _Amount, _Amount + _CloudSoft);
            	
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target
			{	
			    // alpha
			    fixed3 cloud = ( tex2D ( _CloudTex, i.uv3 ) - tex2D( _CloudTex, i.uv4 ) );
			    fixed2 uvMod = cloud.rb * 0.02;
			    fixed alpha = 1 + ( tex2D ( _CloudAlpha, i.uv1 + uvMod ).r - tex2D ( _CloudAlpha, i.uv2 + uvMod ).r );
				
				// color
				fixed3 outcolor = lerp ( _CloudyLightColor.rgb, _CloudyDarkColor.rgb, fixed3(0.5,0.5,0.5) + cloud );
			    fixed outalpha = smoothstep ( i.amt.x, i.amt.y, alpha ) * i.vtc.r;
				
				// return
				return fixed4 ( outcolor.rgb, outalpha * 0.95);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
 }