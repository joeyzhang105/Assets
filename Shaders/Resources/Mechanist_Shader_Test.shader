// Copyright Mechanist Games

// MECHANIST GAMES SHADER TEST
// You will need Unity3d. You will need to find your own models, textures and other materials needed for testing.

// 1. The artist wants this shader to have some color control. Add a tint color to the shader, so artists can control the color from the Unity Inspector.
// 2. The artist tells you the lightmaps are not working. Fix the lightmaps for this shader. You will have to use unity's lightmapping tool to test this.
// 3. Allow the shader to be affected by the ambient light of the scene, which is found in unity's Render Settings. Test this and adjust the brightness.

Shader "Mechanist Tech Artist Shader Test"
{
	Properties
	{
		_MainTex ("Color Texture", 2D) = "white" {}
	}
	
	Subshader
	{
		Tags { "Queue"="Geometry" "IgnoreProjector"="True"}
		LOD 300 //Original master version
		
		Pass
		{
			Tags { "LightMode" = "Always" }
      		Cull Back
			
			CGPROGRAM
				#pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"
							
				struct VertInput
	            {
	                float4 vertex		: POSITION;
	                float2 texcoord		: TEXCOORD;
	                
	     	    	#ifndef LIGHTMAP_OFF
				  		float4 texcoord1: TEXCOORD1;
					#endif
	            };
				
				struct Varys
				{
					half4 pos			: SV_POSITION;
					half2 uv 			: TEXCOORD0;
				
					#ifndef LIGHTMAP_OFF
      		      		half2 uv_light	: TEXCOORD2;
					#endif
				};
				
				uniform sampler2D 	_MainTex;
				uniform float4 		_MainTex_ST;
				uniform float4 		_MainTex_TexelSize;
				
				#ifndef LIGHTMAP_OFF
					uniform sampler2D   unity_Lightmap;
					uniform float4   	unity_LightmapST;
				#endif
				
				Varys vert ( VertInput v )
				{
					Varys o;
						
					// pos and uv tex coord
					o.pos 	= mul (UNITY_MATRIX_MVP, v.vertex);
					o.uv 	= TRANSFORM_TEX ( v.texcoord, _MainTex );
					
					// lightmapping stuff
					#ifndef LIGHTMAP_OFF
   						o.uv_light = ( unity_LightmapST.xy * v.texcoord1.xy ) + unity_LightmapST.zw;
					#endif
					
					return o;
				}
				
				fixed4 frag ( Varys i) : SV_Target
				{
					fixed4 outcolor	= tex2D ( _MainTex, i.uv );
					
					#ifndef LIGHTMAP_OFF
			  			outcolor.xyz *= DecodeLightmap (tex2D ( unity_Lightmap, i.uv ));
					#endif
					
					return outcolor;
				}
			ENDCG
		}
	}
	fallback "VertexLit"
}