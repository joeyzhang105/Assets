using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class BakedAnimationController : MonoBehaviour
{

	[SerializeField]
	public AnimationScriptableObject
		defaultAnimation = null;
	public bool playAutomatically = true;
	public List<AnimationScriptableObject> animationList = new List<AnimationScriptableObject> ();
	Dictionary<string, AnimationScriptableObject> animationDic = new Dictionary<string, AnimationScriptableObject> ();
	MeshFilter meshFilter = null;

	AnimationScriptableObject curPlayingAnimation = null;
	AnimationScriptableObject curLoopingAnimation = null;

	// Use this for initialization
	void Start ()
	{
		Init ();
        //if (playAutomatically && defaultAnimation != null) {


        //    Play (defaultAnimation);
        //    StartCoroutine (Co_Play ());
        //}
	}

	void Init ()
	{
		for (int i = 0; i < animationList.Count; i++) {
			string[] nameBits = animationList [i].name.Split ('@');
			if (nameBits.Length < 1) {
				Debug.LogError ("Wrong Name Format: " + animationList [i].name);
				continue;
			}
			animationDic.Add (nameBits [1], animationList [i]);
		}

		meshFilter = GetComponent<MeshFilter> ();

       // startTime = Time.realtimeSinceStartup;

       
	}


   
	void Update ()
	{
        UpdateAnimationState();
        //if (Input.GetButtonDown("Fire1")) {
        //    Debug.Log("lllllll");
        //    Play ("Attack_1_1");
        //} 
        //else
        //{        
        //    Play("Idle1"); 
        //}
	}


    float startTime = 0;
    public int frameRate = 30;
    public float animationSpeed = 1f;
	void UpdateAnimationState()
	{
        curPlayingAnimation = defaultAnimation;
        
        int totalFrame = curPlayingAnimation.animationData.Count;

        startTime += Time.deltaTime;
        int curFrame =Mathf.FloorToInt (startTime * frameRate  * animationSpeed) %  totalFrame;

        meshFilter.sharedMesh.vertices = curPlayingAnimation.animationData[curFrame].vertices;

	}


	IEnumerator  Co_Play ( )
	{

		    while (true)
		   {

			if(curPlayingAnimation.wrapMode == WrapMode.Loop) 
			{
				Debug.Log ("aaaaa" + curPlayingAnimation.name);
				curPlayingAnimation.isPlaying = true;
				curLoopingAnimation = curPlayingAnimation;
				int i = 0;
				for (i = 0; i < curLoopingAnimation.animationData.Count; ++i) {

					meshFilter.sharedMesh.vertices = curLoopingAnimation.animationData [i].vertices;
					yield return new WaitForSeconds (Time.deltaTime);
					if (i == curLoopingAnimation.animationData.Count - 1) {
						i = 0;
					}
				}
			}
			else //non-loopAnimation
			{
				Debug.Log ("bbbbb" + curPlayingAnimation.name);
				for (int i = 0; i < curPlayingAnimation.animationData.Count; ++i) {
					Debug.Log("CCCC" + curPlayingAnimation.name);
				    curPlayingAnimation.isPlaying = true;
					meshFilter.sharedMesh.vertices = curPlayingAnimation.animationData[i].vertices;
					yield return new WaitForSeconds (Time.deltaTime);
				}
				    curPlayingAnimation = curLoopingAnimation;
					curPlayingAnimation.isPlaying = false;
						 
			  }
		   }

	}

    public	void Play (string aniName)
	{	
		if (animationDic [aniName].isPlaying && animationDic [aniName].wrapMode == WrapMode.Loop)
			return;

		curPlayingAnimation = animationDic [aniName];
		if (curPlayingAnimation.wrapMode != WrapMode.Loop) {
			StopAllCoroutines();
			StartCoroutine(Co_Play());
		}

	}

	public void Play (AnimationScriptableObject animObj)
	{
		curPlayingAnimation = animObj;
	}

	void Stop()
	{
		StopAllCoroutines ();
		foreach(KeyValuePair<string, AnimationScriptableObject> kvp in animationDic) {
			kvp.Value.isPlaying = false;
		}
	}

	void StopAnimation(string _name)
	{
		animationDic [_name].isPlaying = false;
	}

	void StopAnimation(AnimationScriptableObject _obj)
	{
		_obj.isPlaying = false;
	}

	bool IsPlaying()
	{
		foreach(KeyValuePair<string, AnimationScriptableObject> kvp in animationDic) {
			if(kvp.Value.isPlaying){ return true;}
		}

		return false;
	}
	
//	void OnGUI ()
//	{
//
//		if (GUILayout.Button ("Idle")) {
//
//			Play ("Idle1");
//		}
//
//		
//		if (GUILayout.Button ("attack")) {
//			
//			Play ("Attack_1_1");
//		}
//	}
}
