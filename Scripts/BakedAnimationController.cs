using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class BakedAnimationController : MonoBehaviour
{

    [SerializeField]
    public AnimationScriptableObject defaultAnimation = null;
   
    public bool playAutomatically = true;

    public List<AnimationScriptableObject> animationList = new List<AnimationScriptableObject>();

    public int frameRate = 30;
    public float animationSpeed = 1f;



    Dictionary<string, AnimationScriptableObject> animationDic = new Dictionary<string, AnimationScriptableObject>();
    MeshFilter meshFilter = null;
    float startTime = 0;
 
    AnimationScriptableObject curPlayingAnimation = null;

    bool isFrozen = false;

    // Use this for initialization
    void Start()
    {
        Init();
        if (playAutomatically && defaultAnimation != null)
        {
            Play(defaultAnimation);
        }
    }

    void Init()
    {
        meshFilter = GetComponent<MeshFilter>();
        for (int i = 0; i < animationList.Count; i++)
        {
            string[] nameBits = animationList[i].name.Split('@');
            if (nameBits.Length < 1)
            {
                Debug.LogError("Wrong Name Format: " + animationList[i].name);
                continue;
            }
            animationDic.Add(nameBits[1], animationList[i]);
        }
    }



    void Update()
    {
        UpdateAnimationState();
    }


    /// <summary>
    /// 动画的主循环逻辑
    /// </summary>
    void UpdateAnimationState()
    {
        if (curPlayingAnimation == null) return;
        if (isFrozen) return;

        //curPlayingAnimation.isPlaying = true;
        int totalFrame = curPlayingAnimation.animationData.Count;
        startTime += Time.deltaTime;
        int curFrame = Mathf.FloorToInt(startTime * frameRate * animationSpeed) % totalFrame;
        meshFilter.mesh.vertices = curPlayingAnimation.animationData[curFrame].vertices;
        
		if (!string.IsNullOrEmpty(curPlayingAnimation.animationData[curFrame].functionName))
        {
            SendMessage(curPlayingAnimation.animationData[curFrame].functionName, curPlayingAnimation.animationData[curFrame].param,SendMessageOptions.RequireReceiver); 
        }

        if (curPlayingAnimation.wrapMode != WrapMode.Loop && curFrame >= (totalFrame - 1)) //假如不是Loop动画，那么我们播完一次后，就自动回到defaultAnimation的动画
        {
            //curPlayingAnimation.isPlaying = false;
            curPlayingAnimation = defaultAnimation;
            startTime = 0;
        }
    }


    /// <summary>
    /// 播放某个动画
    /// </summary>
    /// <param name="aniName">动画名称</param>
    public void Play(string aniName)
    {
        Play(animationDic[aniName]);
    }

    /// <summary>
    /// 播放某个动画
    /// </summary>
    /// <param name="animObj">具体动画Clip</param>
    public void Play(AnimationScriptableObject animObj)
    {
        isFrozen = false;
        startTime = 0;
        //if (curPlayingAnimation != null) { curPlayingAnimation.isPlaying = false; }//播放新动画前，把当前正在播放的动画的播放状态设成false
        
        curPlayingAnimation = animObj;
    }

	public void Freeze()
	{
		isFrozen = true;
	}


    public void FreezeAtFrame(string _name, int _frame)
    {
        isFrozen = true;
        curPlayingAnimation = animationDic[_name];
        meshFilter.mesh.vertices = curPlayingAnimation.animationData[_frame].vertices;
    }

    public void UnFreeze()
    {
        Play(defaultAnimation);
    }

	/// <summary>
	/// 查询是否有动画被播放中
	/// </summary>
	/// <returns></returns>
	public bool IsPlaying()
	{
		return curPlayingAnimation != null;
	}
	
	/*
	    public void StopAllAnimation()
    {
        curPlayingAnimation = null;
        foreach (KeyValuePair<string, AnimationScriptableObject> kvp in animationDic)
        {
            kvp.Value.isPlaying = false;
        }
    }

    public void StopAnimation(string _name)
    {
        animationDic[_name].isPlaying = false;
    }


    public void StopAnimation(AnimationScriptableObject _obj)
    {
        _obj.isPlaying = false;
    }

    

    
    / <summary>
    / 查询某个动画是否在播放中
    / </summary>
    / <param name="_name"></param>
    / <returns></returns>
    public bool IsPlaying(string _name)
    {
        return animationDic[_name].isPlaying;
    }
   */
}
