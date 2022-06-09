using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamFollow : MonoBehaviour
{
    public Transform objToFollow;
    public float posLerpSpeed;
    public AnimationCurve smoothCurve;
    public TerrainParam terrainParam;
    private Vector3 pos;
   

    // Update is called once per frame
    void Update()
    {
        if (terrainParam.selectedAnimal != null)
        {
            pos = terrainParam.selectedAnimal.transform.position;
        }
        else
        {
            pos = objToFollow.position;
        }

        Follow();

    }

    void Follow()
    {
        
        pos.y = 100;
        transform.position = Vector3.Lerp(transform.position, pos, smoothCurve.Evaluate(Time.fixedDeltaTime * posLerpSpeed));
        
    }
}
