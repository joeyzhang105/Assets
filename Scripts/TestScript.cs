using UnityEngine;
using System.Collections;

[RequireComponent(typeof(BakedAnimationController))]
public class TestScript : MonoBehaviour {


    BakedAnimationController _controller = null;
	// Use this for initialization
	void Start () {
        _controller = GetComponent<BakedAnimationController>();
	}
	
	// Update is called once per frame
	void Update () {
	
	}
    
    void OnGUI()
    {
        if (GUILayout.Button("Run_1"))
        {
            _controller.Play("Run_1");
        }

        if (GUILayout.Button("Show_1"))
        {
            _controller.Play("Show_1");
        }

        if (GUILayout.Button("Freeze"))
        {
            _controller.FreezeAtFrame("Vertigo_1", 18);
        }

        if (GUILayout.Button("UnFreeze"))
        {
            _controller.UnFreeze();
        }
    }

}
