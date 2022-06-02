using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamFollow : MonoBehaviour
{
    public Transform objToFollow;
    public float posLerpSpeed;
    public AnimationCurve smoothCurve;
   

    // Update is called once per frame
    void Update()
    {
        Follow();
    }

    void Follow()
    {
        Vector3 pos = objToFollow.position;
        pos.y = 100;
        transform.position = Vector3.Lerp(transform.position, pos, smoothCurve.Evaluate(Time.fixedDeltaTime * posLerpSpeed));
        
    }
}
