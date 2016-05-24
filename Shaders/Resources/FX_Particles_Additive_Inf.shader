// Copyright Mechanist Games

Shader "Mechanist FX/Particles/2 - Additive (∞)"
{
	Properties {
		_MainTex ("Particle Texture", 2D) = "grey" {}
	}

	Category {
		Tags {
			"Queue" = "Transparent+5"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
		}
		Blend SrcAlpha One
		Cull Off
		Lighting Off
		ZTest Off
		ZWrite Off
		
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		SubShader {
			Pass {
				SetTexture [_MainTex] {
					combine texture * primary
				}
			}
		}
	}
}