using UnityEngine;
using System.Collections;
using System;

[Serializable]
public class AnimationFrame
{
	[SerializeField]
	public int frameIndex;
	public VertexData[] vertices;
    public string functionName = "";
    public string param = "";
}

[Serializable]
public class VertexData
{
    [SerializeField]
    public short x;
    public short y;
    public short z;
}
