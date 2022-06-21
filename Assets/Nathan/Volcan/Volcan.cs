using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Volcan : MonoBehaviour
{
    public Camera cam;
    public GameObject volcan;

    void Update()
    {
        RaycastHit hit;
        Ray ray = cam.ScreenPointToRay(Input.mousePosition);
        if (Input.GetMouseButtonDown(0))
        {

            if (Physics.Raycast(ray, out hit))
            {
                GameObject Volcan = Instantiate(volcan, hit.point, Quaternion.identity);
                Destroy(Volcan, 0.2f);
                Debug.Log(hit.point);
            }
        }
    }
}
