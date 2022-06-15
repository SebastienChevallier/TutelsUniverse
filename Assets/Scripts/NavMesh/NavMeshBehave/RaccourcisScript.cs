using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RaccourcisScript : MonoBehaviour
{
    public TerrainParam terrainParam;

    // Update is called once per frame
    void Update()
    {
        
        if (Input.GetKey(KeyCode.LeftShift))
        {            
            float aoe = Mathf.Clamp((Input.GetAxis("Mouse X") * 10), 0, 100);            
            terrainParam.areaOfEffectSize += (int)aoe;
            
            //Debug.Log((int)Input.GetAxis("Mouse X"));
        }

        if (Input.GetKey(KeyCode.W))
        {
            terrainParam.effectType = TerrainParam.EffectType.raise;
        }

        if (Input.GetKey(KeyCode.X))
        {
            terrainParam.effectType = TerrainParam.EffectType.lower;
        }

        if (Input.GetKey(KeyCode.C))
        {
            terrainParam.effectType = TerrainParam.EffectType.smooth;
        }
    }
}
