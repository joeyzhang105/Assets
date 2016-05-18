using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System;

[Serializable]
public class AnimationScriptableObject : ScriptableObject {

	[SerializeField]
	public List<AnimationFrame> animationData;


	public void OnEnable ()
	{
		//hideFlags = HideFlags.HideAndDontSave;
		if (animationData == null)
			animationData = new List<AnimationFrame> ();
	}

	public void OnDisable() {
		animationData.Clear ();
	}

	[MenuItem("Assets/Create/AnimationScriptableObject")]
	public static void CreateAsset ()
	{
		ScriptableObjectUtility.CreateAsset<AnimationScriptableObject> ();
	}
}




