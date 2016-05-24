// Copyright Mechanist Games

Shader "Mechanist/00 - Shadow Caster"
{
	Properties
	{
	}

	Subshader
	{
		
		Tags {
			"Queue" = "Geometry-10"
			"IgnoreProjector" = "True"
			"LightMode" = "Always"
		}
		
		Pass
		{
			ZTest Off
			ZWrite Off
		}
	}
	FallBack "Diffuse"
}