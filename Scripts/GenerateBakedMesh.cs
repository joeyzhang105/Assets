using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;

public class GenerateBakedMesh : MonoBehaviour {

	SkinnedMeshRenderer smr;



	// Use this for initialization
	void Start () {
	
		smr = GetComponentInChildren<SkinnedMeshRenderer> ();

		if (smr != null) {

			PlayAnimation();
		}
		
	}


	void PlayAnimation()
	{
		animation.Play ("idle1");
		AnimationState clipState = animation ["idle1"];

		float length = clipState.clip.length;
		float frameRate = clipState.clip.frameRate;
	    int totalFrames =(int) (length * frameRate);

		Debug.Log (length + "\t" + frameRate +"\t"+ totalFrames);

		float deltaTime = 1 / frameRate;

		for (int i=0; i< totalFrames; i++) {

			Mesh bakedMesh = new Mesh();

			animation.Sample();
			
			smr.BakeMesh(bakedMesh);
		
			GenerateMesh(bakedMesh,smr.sharedMaterial, i);

			clipState.time += deltaTime;

		}

		animation.Stop ();

	}
	
	void GenerateMesh(Mesh _mesh, Material _mat, int _frame)

	{
		_mesh.uv1 =null;
		_mesh.uv2 =null;
		_mesh.tangents= null;
		_mesh.normals = null;

		Vector3 _pos = new Vector3( _frame*0.5f, 0, 0);

		GameObject go = new GameObject ();
		go.name = "BakedMesh" + _frame;
		go.transform.position = _pos;
		go.transform.eulerAngles = new Vector3 (-90, 0, 0);

		MeshFilter mf = go.AddComponent<MeshFilter> ();
		mf.sharedMesh = _mesh;

		MeshRenderer mr = go.AddComponent<MeshRenderer> ();
		mr.sharedMaterial = _mat;


		string _path = "Assets/Resources/bakedTest/" + _frame +".prefab";
		AssetDatabase.CreateAsset (_mesh, "Assets/Resources/bakedTest/bakedmesh" + _frame +".asset");

		PrefabUtility.CreatePrefab (_path, go);
	

		AssetDatabase.Refresh ();

	}
}
