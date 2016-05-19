using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class BakedAnimationController : MonoBehaviour {

    [SerializeField]
    public List<AnimationScriptableObject> animationList = new List<AnimationScriptableObject>();

    Dictionary<string, AnimationScriptableObject> animationDic = new Dictionary<string, AnimationScriptableObject>();

    MeshFilter meshFilter = null;

    public int _fps = 10;
    private int lastIndex = -1;

    // Use this for initialization
	void Start () {
        Init();
	}


    void Init()
    {
        for (int i = 0; i < animationList.Count; i++)
        {
            string[] nameBits = animationList[i].name.Split('@');
            if(nameBits.Length < 1){ Debug.LogError("Wrong Name Format: " + animationList[i].name); continue; }
            animationDic.Add(nameBits[1], animationList[i]);
        }

        meshFilter = GetComponent<MeshFilter>();

       //StartCoroutine(Co_Play("Idle1"));
    }



     void Update()
    {
       Play("Idle1");
	}

    //TODO
     public void Play(string aniName)
     {

         int index = (int)(Time.timeSinceLevelLoad * _fps) % animationDic[aniName].animationData.Count;
         Debug.Log(index);
         
             for (int i = 0; i < animationDic[aniName].animationData.Count; i++)
             {
                 if (index != lastIndex)
                 {
                    meshFilter.sharedMesh.vertices = animationDic[aniName].animationData[i].vertices;
                    lastIndex = index;
                 }  
         }
     }


    IEnumerator  Co_Play(string aniName)
    {
        for (int i = 0; i < animationDic[aniName].animationData.Count; i++)
        {
            meshFilter.sharedMesh.vertices = animationDic[aniName].animationData[i].vertices;
            yield return new WaitForSeconds(Time.deltaTime);
        }

        yield break;
    }
}
