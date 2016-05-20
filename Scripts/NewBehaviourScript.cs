using UnityEngine;
using System.Collections;

public class NewBehaviourScript : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnGUI()
	{

		if (GUILayout.Button ("Play")) {
			animation.CrossFade("Attack_1_1");}
	}
}
