using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;

public class BuildAnimationData : MonoBehaviour {

    [MenuItem("Assets/Build AnimationData From Selection")]
    static void BuildAnimationDataFromSelection()
    {
            string _name = Selection.activeGameObject.name;
            string _dir = Application.dataPath;
            string _path = EditorUtility.SaveFilePanel("Save Resource", _dir, _name, "");
            if (_path.Length != 0)
            {
                GameObject _go = Instantiate((GameObject)Selection.activeGameObject) as GameObject;
               
                SkinnedMeshRenderer _smr = _go.GetComponentInChildren<SkinnedMeshRenderer>();
                Mesh bakedMesh = new Mesh();
                _smr.BakeMesh(bakedMesh);

                int index = _path.IndexOf("Assets");
                string shortPath = _path.Substring(index);

                GameObject bakedGO =  GenerateBakedGameObject(Selection.activeGameObject.name, bakedMesh, _smr.sharedMaterial, shortPath);

                GenerateAnimationData(_go, shortPath, bakedGO);

                DestroyImmediate(_go);
            }
    }


    static GameObject GenerateBakedGameObject(string _name, Mesh _mesh, Material _mat, string _path)
	{
		_mesh.uv1 =null;
		_mesh.uv2 =null;
		_mesh.tangents= null;
		_mesh.normals = null;


		GameObject go = new GameObject ();
		MeshFilter mf = go.AddComponent<MeshFilter> ();
		mf.sharedMesh = _mesh;

		MeshRenderer mr = go.AddComponent<MeshRenderer> ();
		mr.sharedMaterial = _mat;

        go.name = _name;




        AssetDatabase.CreateAsset(_mesh, _path  + ".asset");
        GameObject _newGO = PrefabUtility.CreatePrefab(_path  + ".prefab", go);
        
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh ();

        DestroyImmediate(go);
        return _newGO;
	}


    static void GenerateAnimationData(GameObject _go, string _path, GameObject _newGO)
    {
        BakedAnimationController _bac = _newGO.AddComponent<BakedAnimationController>();
        
        _go.animation.Stop();
        _go.animation.playAutomatically = false;
              
        foreach (AnimationState aniState in _go.animation)
        {
           aniState.time = 0;
           
           float length = aniState.clip.length;
           float frameRate = aniState.clip.frameRate;
           int totalFrames = (int)(length * frameRate);

           Debug.Log(aniState.name + "-- length: " + length + "\t FrameRate: " + frameRate + "\t TotalFrames: " + totalFrames);

            AnimationScriptableObject aniObject = ScriptableObject.CreateInstance<AnimationScriptableObject>();
            AssetDatabase.CreateAsset(aniObject, _path + "@" + aniState.name + ".asset");

            float deltaTime = 1 / frameRate;

            _go.animation.Play(aniState.name, PlayMode.StopAll);

            for (int i = 0; i < totalFrames; i++)
            {
                Mesh bakedMesh = new Mesh();

                _go.animation.Sample();

                SkinnedMeshRenderer _smr = _go.GetComponentInChildren<SkinnedMeshRenderer>();
                _smr.BakeMesh(bakedMesh);


                AnimationFrame _frame = new AnimationFrame();
                _frame.frameIndex = i;
                _frame.vertices = bakedMesh.vertices;
                aniObject.animationData.Add(_frame);

                aniState.time += deltaTime;

                DestroyImmediate(bakedMesh);
            }

              
            EditorUtility.SetDirty(aniObject);

            _bac.animationList.Add(aniObject);
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        EditorUtility.FocusProjectWindow();

    }

}
