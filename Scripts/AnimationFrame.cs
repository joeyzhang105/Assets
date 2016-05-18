using UnityEngine;
using System.Collections;
using System;

[Serializable]
public class AnimationFrame
{
	[SerializeField]
	public int frameIndex;
	public Vector3[] vertices;
}
