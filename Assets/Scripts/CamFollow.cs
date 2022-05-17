using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamFollow : MonoBehaviour
{
    public Transform objToFollow;
    public float posLerpSpeed;
    public float rotaLerpSpeed;

    // Update is called once per frame
    void Update()
    {
        Follow();
    }

    void Follow()
    {
        transform.position = Vector3.Lerp(transform.position, objToFollow.position, Time.deltaTime * posLerpSpeed);
        
    }
}
