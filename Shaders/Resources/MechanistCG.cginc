// Mechanist Lighting CG Include
// Dave Lindsay

// Global Lighting
uniform fixed3 _Gbl_Lgt;
uniform fixed3 _Gbl_Pnt;
uniform fixed3 _Gbl_Amb;
uniform fixed3 _Gbl_Spc;
uniform fixed3 _Gbl_Rim;
uniform fixed3 _Gbl_Wat;
uniform fixed3 _Gbl_Sfx1;
uniform float _FogDistMin;
uniform float _FogDistMax;
uniform fixed3 _FogColor;
uniform fixed _FogClamp;
			
#ifdef LIGHTMAP_ON
	uniform sampler2D unity_Lightmap;
	uniform half4 unity_LightmapST;
#endif

inline fixed inlineFogVert ( float3 worldVertex ) {
	float fogDistance = length ( worldVertex.xyz - _WorldSpaceCameraPos.xyz ) - _FogDistMin;
	fixed fogAmount = clamp ( fogDistance / _FogDistMax, 0, _FogClamp );
	return fogAmount;
}

inline fixed3 inlineFogFrag ( fixed3 outcolor, float fogAmount ) {
	outcolor = lerp ( outcolor, _FogColor, fogAmount );
	return outcolor;
}

// Dynamic Lighting
//#ifdef LIGHTS_4
//	uniform half4 _4LightColorR0;
//	uniform half4 _4LightColorG0;
//	uniform half4 _4LightColorB0;
//	uniform half4 _4LightPosX0; 
//	uniform half4 _4LightPosY0;
//	uniform half4 _4LightPosZ0;
//	uniform half4 _4LightRange0;
//#endif
//#ifdef LIGHTS_8
//	uniform half4 _4LightColorR0;
//	uniform half4 _4LightColorG0;
//	uniform half4 _4LightColorB0;
//	uniform half4 _4LightPosX0; 
//	uniform half4 _4LightPosY0;
//	uniform half4 _4LightPosZ0;
//	uniform half4 _4LightRange0;
//	
//	uniform half4 _4LightColorR1;
//	uniform half4 _4LightColorG1;
//	uniform half4 _4LightColorB1;
//	uniform half4 _4LightPosX1; 
//	uniform half4 _4LightPosY1;
//	uniform half4 _4LightPosZ1;
//	uniform half4 _4LightRange1;
//#endif
//#ifdef LIGHTS_12
//	uniform half4 _4LightColorR0;
//	uniform half4 _4LightColorG0;
//	uniform half4 _4LightColorB0;
//	uniform half4 _4LightPosX0; 
//	uniform half4 _4LightPosY0;
//	uniform half4 _4LightPosZ0;
//	uniform half4 _4LightRange0;
//	
//	uniform half4 _4LightColorR1;
//	uniform half4 _4LightColorG1;
//	uniform half4 _4LightColorB1;
//	uniform half4 _4LightPosX1; 
//	uniform half4 _4LightPosY1;
//	uniform half4 _4LightPosZ1;
//	uniform half4 _4LightRange1;
//	
//	uniform half4 _4LightColorR2;
//	uniform half4 _4LightColorG2;
//	uniform half4 _4LightColorB2;
//	uniform half4 _4LightPosX2; 
//	uniform half4 _4LightPosY2;
//	uniform half4 _4LightPosZ2;
//	uniform half4 _4LightRange2;
//#endif

#ifdef BEND_3
	uniform half3 _ObjPos0;
	uniform half3 _ObjPos1;
	uniform half3 _ObjPos2;
	uniform half _ObjRange;
	uniform half _BendDist;
#endif
#ifdef BEND_6
	uniform half3 _ObjPos0;
	uniform half3 _ObjPos1;
	uniform half3 _ObjPos2;
	uniform half3 _ObjPos3;
	uniform half3 _ObjPos4;
	uniform half3 _ObjPos5;
	uniform half _ObjRange;
	uniform half _BendDist;
#endif
#ifdef BEND_9
	uniform half3 _ObjPos0;
	uniform half3 _ObjPos1;
	uniform half3 _ObjPos2;
	uniform half3 _ObjPos3;
	uniform half3 _ObjPos4;
	uniform half3 _ObjPos5;
	uniform half3 _ObjPos6;
	uniform half3 _ObjPos7;
	uniform half3 _ObjPos8;
	uniform half _ObjRange;
	uniform half _BendDist;
#endif

//inline half3 inlineLights ( half3 worldPos ) {
//	half3 lgt = (0,0,0);
//	half attenuation;
//	half3 lightPos;
//	#ifdef LIGHTS_4
//		for ( int loop = 0; loop < 4; loop++ ) {
//			lightPos = half3 ( _4LightPosX0[loop], _4LightPosY0[loop], _4LightPosZ0[loop] );
//			attenuation = clamp ( ( 1.0 - ( length ( lightPos - worldPos ) / _4LightRange0[loop] ) ), 0, 1 );
//			lgt += attenuation * half3 ( _4LightColorR0[loop],_4LightColorG0[loop], _4LightColorB0[loop] );
//		}
//	#endif
//	#ifdef LIGHTS_8
//		for ( int loop = 0; loop < 4; loop++ ) {
//			lightPos = half3 ( _4LightPosX0[loop], _4LightPosY0[loop], _4LightPosZ0[loop] );
//			attenuation = clamp ( ( 1.0 - ( length ( lightPos - worldPos ) / _4LightRange0[loop] ) ), 0, 1 );
//			lgt += attenuation * half3 ( _4LightColorR0[loop],_4LightColorG0[loop], _4LightColorB0[loop] );
//		}
//		for ( int loop = 0; loop < 4; loop++ ) {
//			lightPos = half3 ( _4LightPosX1[loop], _4LightPosY1[loop], _4LightPosZ1[loop] );
//			attenuation = clamp ( ( 1.0 - ( length ( lightPos - worldPos ) / _4LightRange1[loop] ) ), 0, 1 );
//			lgt += attenuation * half3 ( _4LightColorR1[loop],_4LightColorG1[loop], _4LightColorB1[loop] );
//		}
//	#endif
//	#ifdef LIGHTS_12
//		for ( int loop = 0; loop < 4; loop++ ) {
//			lightPos = half3 ( _4LightPosX0[loop], _4LightPosY0[loop], _4LightPosZ0[loop] );
//			attenuation = clamp ( ( 1.0 - ( length ( lightPos - worldPos ) / _4LightRange0[loop] ) ), 0, 1 );
//			lgt += attenuation * half3 ( _4LightColorR0[loop],_4LightColorG0[loop], _4LightColorB0[loop] );
//		}
//		for ( int loop = 0; loop < 4; loop++ ) {
//			lightPos = half3 ( _4LightPosX1[loop], _4LightPosY1[loop], _4LightPosZ1[loop] );
//			attenuation = clamp ( ( 1.0 - ( length ( lightPos - worldPos ) / _4LightRange1[loop] ) ), 0, 1 );
//			lgt += attenuation * half3 ( _4LightColorR1[loop],_4LightColorG1[loop], _4LightColorB1[loop] );
//		}
//		for ( int loop = 0; loop < 4; loop++ ) {
//			lightPos = half3 ( _4LightPosX2[loop], _4LightPosY2[loop], _4LightPosZ2[loop] );
//			attenuation = clamp ( ( 1.0 - ( length ( lightPos - worldPos ) / _4LightRange2[loop] ) ), 0, 1 );
//			lgt += attenuation * half3 ( _4LightColorR2[loop],_4LightColorG2[loop], _4LightColorB2[loop] );
//		}
//	#endif
//	return lgt;
//}

inline half2 inlineGrassBend ( half3 worldVertex ) {
	half2 tempPos = (0,0);
	#ifdef BEND_3
		half3 bendDir;
		half vertDist;
		half bendDist;
		// character 1
			bendDir = normalize ( worldVertex - _ObjPos0 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos0 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 2
			bendDir = normalize ( worldVertex - _ObjPos1 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos1 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 3
			bendDir = normalize ( worldVertex - _ObjPos2 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos2 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// distance of displacement
			tempPos *= _BendDist;
			tempPos.x = clamp(tempPos.x, -_BendDist,_BendDist);
			tempPos.y = clamp(tempPos.y, -_BendDist,_BendDist);
	#endif
	#ifdef BEND_6
		half3 bendDir;
		half vertDist;
		half bendDist;
		// character 1
			bendDir = normalize ( worldVertex - _ObjPos0 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos0 ) );
            bendDist = ( _ObjRange - vertDist ) / _ObjRange;
            tempPos += bendDir.xz * bendDist;
		// character 2
			bendDir = normalize ( worldVertex - _ObjPos1 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos1 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 3
			bendDir = normalize ( worldVertex - _ObjPos2 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos2 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 4
			bendDir = normalize ( worldVertex - _ObjPos3 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos3 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 5
			bendDir = normalize ( worldVertex - _ObjPos4 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos4 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 6
			bendDir = normalize ( worldVertex - _ObjPos5 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos5 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// distance of displacement
			tempPos *= _BendDist;
			tempPos.x = clamp(tempPos.x, -_BendDist,_BendDist);
			tempPos.y = clamp(tempPos.y, -_BendDist,_BendDist);
	#endif
	#ifdef BEND_9
		half3 bendDir;
		half vertDist;
		half bendDist;
		// character 1
			bendDir = normalize ( worldVertex - _ObjPos0 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos0 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 2
			bendDir = normalize ( worldVertex - _ObjPos1 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos1 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 3
			bendDir = normalize ( worldVertex - _ObjPos2 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos2 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 4
			bendDir = normalize ( worldVertex - _ObjPos3 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos3 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 5
			bendDir = normalize ( worldVertex - _ObjPos4 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos4 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 6
			bendDir = normalize ( worldVertex - _ObjPos5 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos5 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 7
			bendDir = normalize ( worldVertex - _ObjPos6 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos6 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 8
			bendDir = normalize ( worldVertex - _ObjPos7 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos7 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// character 9
			bendDir = normalize ( worldVertex - _ObjPos8 );
			vertDist = min ( _ObjRange, distance ( worldVertex, _ObjPos8 ) );
			bendDist = ( _ObjRange - vertDist) / _ObjRange;
			tempPos += bendDir.xz * bendDist;
		// distance of displacement
			tempPos *= _BendDist;
			tempPos.x = clamp(tempPos.x, -_BendDist,_BendDist);
			tempPos.y = clamp(tempPos.y, -_BendDist,_BendDist);
	#endif
	return tempPos;
}

inline half inlinePlantSquash ( half3 worldVertex ) {
	half tempPos = 0;
	#ifdef BEND_3
		half vertDist;
		half bendDist;
		half plantDist = _BendDist * 1.666;
		half plantRange = _ObjRange * 0.666;
		// character 1
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos0 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 2
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos1 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 3
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos2 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// distance of displacement
			tempPos = clamp(tempPos, -plantRange,plantRange);
	#endif
	#ifdef BEND_6
		half vertDist;
		half bendDist;
		half plantDist = _BendDist * 1.666;
		half plantRange = _ObjRange * 0.666;
		// character 1
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos0 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 2
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos1 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 3
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos2 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 4
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos3 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 5
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos4 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 6
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos5 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// distance of displacement
			tempPos = clamp(tempPos, -plantRange,plantRange);
	#endif
	#ifdef BEND_9
		half vertDist;
		half bendDist;
		half plantDist = _BendDist * 1.666;
		half plantRange = _ObjRange * 0.666;
		// character 1
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos0 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 2
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos1 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 3
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos2 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 4
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos3 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 5
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos4 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 6
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos5 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 7
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos6 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 8
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos7 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// character 9
			vertDist = min ( plantRange, distance ( worldVertex, _ObjPos8 ) );
			bendDist = ( plantRange - vertDist) / plantRange;
			tempPos += bendDist;
		// distance of displacement
			tempPos = clamp(tempPos, -plantRange,plantRange);
	#endif
	return tempPos;
}
	
inline half2 inlineLightmapTransform ( half2 coords ) {
	#ifdef LIGHTMAP_ON
   		half2 uv2 = ( unity_LightmapST.xy * coords ) + unity_LightmapST.zw;
	#else
		half2 uv2 = coords;
	#endif
	return uv2;
}

inline fixed inlineShadow ( fixed shd ) {
	//fixed hardness = smoothstep ( 0.3, 0.7, shd );
	//fixed hardness = step (0.5,shd);
	fixed hardness = shd;
	return hardness;
}

inline fixed3 inlineLightmapWithShadows ( half2 uv, half shd ) {
	#ifdef LIGHTMAP_ON
		fixed3 lm = tex2D ( unity_Lightmap, uv );
		//fixed3 lightmap = _Gbl_Amb + shd * lm.r * _Gbl_Lgt + lm.g * _Gbl_Pnt;
		fixed3 lightmap = _Gbl_Amb + shd * lm.r * _Gbl_Lgt + lm.g * _Gbl_Pnt;
	#else
		fixed3 lightmap = (1,1,1);
	#endif
	return lightmap;
}


inline fixed3 inlineLightmapBasic ( half2 uv ) {
	#ifdef LIGHTMAP_ON
		fixed3 lm = tex2D ( unity_Lightmap, uv );
		//fixed3 lightmap = _Gbl_Amb + lm.r * _Gbl_Lgt + lm.g * _Gbl_Pnt;
		fixed3 lightmap = _Gbl_Amb + lm.r * _Gbl_Lgt + lm.g * _Gbl_Pnt;
	#else
		fixed3 lightmap = (1,1,1);
	#endif
	return lightmap;
}

inline fixed3 inlineVLM_Full ( fixed4 vc ) {
	fixed3 vlmlight = _Gbl_Amb + _Gbl_Lgt * vc.r + _Gbl_Pnt * vc.g;
	return vlmlight;
}

inline half3 inlineVLM_Amb ( half4 amb ) {
	half3 amblight = _Gbl_Amb + amb.g * _Gbl_Pnt;
	return amblight;
}

inline fixed3 inlineVLM_Shade ( fixed3 sun, fixed shd ) {
	fixed3 shdlight = shd.xxx * sun;
	return shdlight;
}

inline fixed3 inlineVLM_Sun ( fixed sun ) {
	fixed3 sunlight = sun * _Gbl_Lgt;
	return sunlight;
}

inline half2 inlineShadeProbes (half4 normal)
{
	half4 vB = normal.xyzz * normal.yzzx;
	half vC = normal.x * normal.x - normal.y * normal.y;
	
	half2 x1, x2, x3;
	x1.r = dot(unity_SHAr,normal);
	x1.g = dot(unity_SHAg,normal);
	x2.r = dot(unity_SHBr,vB);
	x2.g = dot(unity_SHBg,vB);
	x3 = unity_SHC.rg * vC;
	
    return x1 + x2 + x3;
} 

inline half3 inlineShadowBasic ( half shd ) {
	half3 shdcolor = _Gbl_Amb + shd * _Gbl_Lgt;
	return shdcolor;
}