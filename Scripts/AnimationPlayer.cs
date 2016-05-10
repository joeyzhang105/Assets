using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class AnimationPlayer : MonoBehaviour {

	List<GameObject> goGroup = new List<GameObject>();
	GameObject currentGO;


	// Use this for initialization
	void Start () {

		GameObject[] _gos = Resources.LoadAll<GameObject>("bakedTest");

	
		foreach (GameObject _go in _gos) {
			goGroup.Add (_go);
		}

		CompareID _ComID = new CompareID ();
		
		goGroup.Sort (_ComID);

		StartCoroutine (PlayBakedAnimation ());
	}

	IEnumerator PlayBakedAnimation()
	{
		for (int  i =0; i< 69/3; i++) {
			if (currentGO != null) {
				Destroy (currentGO);
			}
			currentGO = (GameObject)Instantiate (goGroup [i], Vector3.zero, Quaternion.Euler(new Vector3(-90,180,0)));

			//float deltaTime = 2.3f/69f;
			//Debug.Log(Time.fixedDeltaTime);

			yield return new WaitForSeconds(Time.fixedDeltaTime *3.5f);
		}

		yield break;
	}

	public class CompareID: IComparer<UnityEngine.GameObject>
	{
		public int Compare(GameObject a, GameObject b)
		{
			return  int.Parse(a.name) - int.Parse(b.name);
		}
	}
	

}


