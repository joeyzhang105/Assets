// Copyright Mechanist Games
// Dave Lindsay

Shader "Mechanist CITY/Clouds"
{
	Properties
	{
		_ShadowSize ("Shadow Size", Float) = 0.5
		_ShadowOffset ("Shadow Offset", Float) = 0.5
		_TilesPerMeter1 ("Alpha Tiling, XY, XY", Vector) = (1,1,1,1)
		_TilesPerMeter2 ("Texture Tiling, XY, XY", Vector) = (1,1,1,1)
		_Color2 ("Cloud Dark Color", Color ) = (1,1,1,1)
		_Color1 ("Cloud Light Color", Color ) = (1,1,1,1)
		_Amount ("Cloud Amount (1.0)", Float) = 1
		_Soft ("Cloud Softness (0.3)", Float) = 0.25
		_WindSpeed ("Alpha: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		_TexSpeed ("Texture: UV Speed (xy), UV Speed (zw)", Vector) = (1.3,-1.4,-1.5,1.6)
		
		_CloudAlpha ("Cloud Alpha", 2D) = "white" { }
		_CloudTex ("Cloud Texture", 2D) = "white" { }
		_Airship ("Airship Shadow", 2D) = "white" { }
	}
	
	SubShader {
		
		Tags {
			"Queue" = "Transparent-1"
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
			
			#pragma fragmentoption ARB_precision_hint_fastest
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
			    float2 uv5 : TEXCOORD4;
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
			uniform fixed4 _Color1;
			uniform fixed4 _Color2;
			uniform fixed _Amount;
			uniform fixed _Soft;
			uniform float _ShadowOffset;
			
			// global properties
			uniform fixed _TotalBrightness;
			
			vertShader vert ( vertInput v )
			{
			    vertShader o;
				float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
			    
			    // UV calculation
				o.uv1 = v.texcoord * _TilesPerMeter1.xy + float2 ( _Time.xx * _WindSpeed.xy);
				o.uv2 = v.texcoord * _TilesPerMeter1.zw + float2 ( _Time.xx * _WindSpeed.zw);
				o.uv3 = v.texcoord * _TilesPerMeter2.xy + float2 ( _Time.xx * _TexSpeed.xy );
				o.uv4 = v.texcoord * _TilesPerMeter2.zw + float2 ( _Time.xx * _TexSpeed.zw );
				o.uv5 = (v.texcoord - float2(0.5,0.5)) * _ShadowSize + float2(0.5,0.5) - _WorldSpaceLightPos0.xz * _ShadowOffset;
				
				// pos and uv tex coord
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			    
			    // vertex color
			    o.vtc = v.color;
            	
			    return o;
			}
			
			fixed4 frag (vertShader i) : SV_Target
			{	
			    // alpha
			    fixed3 cloud = ( tex2D ( _CloudTex, i.uv3 ) - tex2D( _CloudTex, i.uv4 ) );
			    fixed2 uvMod = cloud.rb * 0.02;
			    fixed3 alpha = ( tex2D ( _CloudAlpha, i.uv1 + uvMod ) - tex2D ( _CloudAlpha, i.uv2 + uvMod ) );
				
				// color
				fixed3 outcolor = lerp ( _Color1.rgb, _Color2.rgb, fixed3(0.5,0.5,0.5) + cloud );
			    fixed outalpha = smoothstep ( _Amount, _Amount + _Soft, (1+alpha.r) * i.vtc.a ) * i.vtc.r;
				
				// shadow
				uvMod += alpha * 0.05;
				outcolor.rgb *= tex2D (_Airship, i.uv5 + uvMod);
				
				// return
				return fixed4 ( outcolor.rgb * _TotalBrightness, 0.95 * outalpha );
			}
			ENDCG
		}
	}
	//Fallback "Diffuse"
 }