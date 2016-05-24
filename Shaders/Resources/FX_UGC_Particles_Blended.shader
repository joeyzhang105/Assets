// Copyright Mechanist Games

Shader "Mechanist FX/UGC/Particle Blended 还不会用"
{
	Properties {
		_MainTex ("Particle Texture", 2D) = "grey" {}
	}

	Category {
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
		}
		
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		Lighting Off
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