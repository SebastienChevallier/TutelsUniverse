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
        transform.position = Vector3.Lerp(transform.position, objToFollow.position, smoothCurve.Evaluate(Time.fixedDeltaTime * posLerpSpeed));
        
    }
}
