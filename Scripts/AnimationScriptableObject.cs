using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System;

[Serializable]
public class AnimationScriptableObject : ScriptableObject {

	[SerializeField]
	public List<AnimationFrame> animationData = new List<AnimationFrame>();
	[SerializeField]
	public WrapMode wrapMode = WrapMode.Default;
    
	[NonSerialized]
	public bool isPlaying = false;
    
	//public void OnEnable()
    //{
    //    //hideFlags = HideFlags.HideAndDontSave;
    //    if (animationData == null)
    //        animationData = new List<AnimationFrame>();
    //}

    //public void OnDisable() {
    //    animationData.Clear ();
    //}
}




