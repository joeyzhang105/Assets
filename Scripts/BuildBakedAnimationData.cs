using UnityEngine;
using System.Collections;

public class BuildBakedAnimationData : MonoBehaviour {


	public MeshFilter mf1;

	public MeshFilter mf2;

	public Vector3[] vertices1;

	//public Vector3[] vertices2;
	//public int[] indices;

	// Use this for initialization
	void Start () {

		Debug.Log("VertexCout: " + mf1.mesh.vertexCount);
		//indices = mf.mesh.GetIndices(0);
		//vertices = new Vector3[mf.mesh.vertexCount];
		vertices1 = mf1.mesh.vertices;

	 
	}

	void OnGUI()
	{

		if (GUILayout.Button ("Click")) {

			mf2.mesh.vertices = vertices1;
		}
	}

}
