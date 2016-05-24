// Copyright Mechanist Games

Shader "Mechanist CITY/Statue"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormTex ("Normals", 2D) = "white" {}
		_DissTex ("Dissolve", 2D) = "white" {}
		_Blender ("Blend Material", float) = 50
		_Shine ("Shine Material", range(0,3)) = 0
		_ActiveColor0 ("Active Metal Color Dark",Color) = (1,1,1,1)
		_ActiveColor1 ("Active Metal Color Bright",Color) = (1,1,1,1)
		_Angle ("Unity Shadow Flicker Override Angle", Range(0.2,0.8)) = 0.4
		_LocalSunColor ("City Sun Color", Color) = (0.8,0.6,0.4,1)
	}
	
	Subshader
	{
		Tags {
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"LightMode" = "ForwardBase"
		}
		
		Pass
		{
      		Cull Off
      		Fog {Mode Off}
      		
      		CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash d3d11
			
			#include "UnityCG.cginc"
			
			struct VertInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
			
			struct vertShader
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD7;
				float3 nrm : TEXCOORD2;
				float3 bin : TEXCOORD3;
				float3 tng : TEXCOORD4;
				float3 cam : TEXCOORD5;
				fixed stp : TEXCOORD6;
			};
			
			// resources
			uniform sampler2D _MainTex;
			uniform sampler2D _NormTex;
			uniform sampler2D _DissTex;
			uniform float4 _MainTex_ST;
			
			// properties
			uniform float _Angle;
			uniform float _Blender;
			uniform float _Shine;
			uniform fixed3 _ActiveColor0;
			uniform fixed3 _ActiveColor1;
			uniform fixed3 _LocalSunColor;
			
			vertShader vert ( VertInput v )
			{
				vertShader o;
               	float3 worldVertex = mul ( _Object2World, v.vertex ).xyz;
		
				// pos and uv tex coord
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX ( v.texcoord0, _MainTex );
				o.uv2 = o.uv1 + float2(_Time.x,-_Time.x);
				o.uv3 = o.uv1 * 1.1 - float2(_Time.x,_Time.x);
				
				// diffuse reflection
				o.nrm = normalize ( mul ( float4 ( v.normal, 0.0 ), _World2Object ).xyz );
				o.tng = normalize ( mul ( _Object2World, float4 ( v.tangent.xyz, 0.0 ) ).xyz );
            	o.bin = normalize ( cross ( o.nrm, o.tng ) * v.tangent.w );
				o.cam = normalize ( WorldSpaceViewDir (v.vertex) );
            	
            	// step
				o.stp = (_Blender/100 + v.vertex.x * 5);
																																		
				return o;
			}
						
			fixed4 frag ( vertShader i ) : SV_Target {
				fixed4 texcolor = tex2D ( _MainTex, i.uv1 );
				fixed3 bumpmap = tex2D ( _NormTex, i.uv1 ) - fixed3(0.5,0.5,0.5);
				fixed3 dissolve = tex2D ( _DissTex, i.uv2 ) * tex2D ( _DissTex, i.uv3 );
				
				// normals
				fixed3x3 matrixDIR = float3x3 (i.tng, i.bin, i.nrm);
				fixed3 normDIR = normalize ( mul ( bumpmap, matrixDIR ) );
				
				// reflection
				fixed3 reflight = lerp (_ActiveColor0,_ActiveColor1,texcolor.a*2);
				
				// mix
				fixed stepper = smoothstep(0.43, 0.57, i.stp - texcolor.a);
				fixed3 outcolor = lerp ( texcolor, reflight, stepper);
				
				// shadows
				outcolor *= 0.5 + 0.5 * max(0,dot(_WorldSpaceLightPos0, normDIR));
				
				// specular
				fixed dotprod = max (0, dot( normDIR, i.cam));
				outcolor += _LocalSunColor * pow(dotprod,10) * (0.4 + 0.6 * stepper);
				
				// line
				outcolor += stepper * (1-stepper) * 2;
				
				// glow
				fixed glowy = smoothstep(0.23,0.3,dissolve);
				outcolor += stepper * glowy * (1-glowy) * 1.5;
				
				return fixed4(outcolor,1);
			}
		ENDCG
		}
	}
	FallBack "VertexLit"
}