using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectAnimal : MonoBehaviour
{
    public TerrainParam terrainParam;
    public LayerMask layer;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0) && terrainParam.isSelectAnimal)
            FocusAnimal();
    }

    public void FocusAnimal()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if(Physics.Raycast(ray, out hit, 500f, layer))
        {
            terrainParam.selectedAnimal = hit.transform.gameObject;
        }
    }
}
