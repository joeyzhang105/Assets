using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System;

public class AnimationPlayer : MonoBehaviour {

	List<GameObject> goGroup = new List<GameObject>();
	GameObject currentGO1;
	public MeshFilter testMesh1;
	public MeshFilter testMesh2;
	public MeshFilter testMesh3;
	public MeshFilter testMesh4;

	public int totalFrames = 48;

	//[SerializeField]
	//public Vector3[][] verticesList;
	[SerializeField]
	public AnimationScriptableObject aniObject;

	// Use this for initialization
	void Start() {


	
	}

	void OnGUI()
	{
		if(GUILayout.Button("Bake"))
		{ 
			for(int i=0; i<10;i++)
			Bake();
		}
		
		if(GUILayout.Button("PlayNow"))
		{
			StartCoroutine(PlayBakedAnimationTest());
		}

		if (GUILayout.Button ("Destroy")) {
			if(aso!=null){
				aso = null;
			}

			Resources.UnloadUnusedAssets();
			GC.Collect();
		}
	}

	void Bake()
	{
		GameObject[] _gos = Resources.LoadAll<GameObject>("bakedTest");
		
		
		foreach (GameObject _go in _gos) {
			goGroup.Add (_go);
		}
		
		CompareID _ComID = new CompareID ();
		
		goGroup.Sort (_ComID);
		
		//aniObject.animationData.Clear ();
		
		for (int i=0; i<totalFrames; i++) {
			
			GameObject _tempGO = Instantiate(goGroup[i]) as GameObject;
			MeshFilter mf = _tempGO.GetComponent<MeshFilter>();
			
			AnimationFrame _frame = new AnimationFrame();
			_frame.frameIndex = i;
			_frame.vertices = mf.sharedMesh.vertices;
			aniObject.animationData.Add(_frame);
			
			Destroy(_tempGO);
		}
		EditorUtility.SetDirty (aniObject);
	   
		AssetDatabase.SaveAssets ();
		AssetDatabase.Refresh ();
	}

	AnimationScriptableObject aso;
	IEnumerator PlayBakedAnimationTest()
	{
		string path = Application.dataPath + "/testAsset.unity3d";
		Debug.Log (path);
		AssetBundle ab = AssetBundle.CreateFromFile (path);
		if (aso == null) {
			aso = ab.Load ("aniObj", typeof(AnimationScriptableObject)) as AnimationScriptableObject;
		}
		ab.Unload (false );

		if (aso != null) {
			Debug.Log(aso.name);
			for (int i =0; i<totalFrames; i++) {
				testMesh1.mesh.vertices = aso.animationData [i].vertices;
				testMesh2.mesh.vertices = aso.animationData [i].vertices;
				testMesh3.mesh.vertices = aso.animationData [i].vertices;
				testMesh4.mesh.vertices = aso.animationData [i].vertices;
				yield return new WaitForSeconds (Time.fixedDeltaTime);
			}
		}
		yield break;
	}



	IEnumerator PlayBakedAnimation()
	{
		for (int  i =0; i< totalFrames; i++) {
			if (currentGO1 != null) {
				Destroy (currentGO1);
			}
			currentGO1 = (GameObject)Instantiate (goGroup [i], Vector3.zero, Quaternion.Euler(new Vector3(0,180,0)));


			//float deltaTime = 2.3f/69f;
			//Debug.Log(Time.fixedDeltaTime);

			yield return new WaitForSeconds(Time.fixedDeltaTime);
		}

		yield break;
	}
	
}

public class CompareID: IComparer<UnityEngine.GameObject>
{
	public int Compare(GameObject a, GameObject b)
	{
		return  int.Parse(a.name) - int.Parse(b.name);
	}
}
