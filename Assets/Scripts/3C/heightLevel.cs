using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class heightLevel : MonoBehaviour
{
    public LayerMask mask;
    private GameObject playerLookAt;

    // Start is called before the first frame update
    void Start()
    {
        playerLookAt = transform.GetChild(0).gameObject;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetAxis("Horizontal") != 0 || Input.GetAxis("Vertical") != 0)
            CheckHeights();
    }   

    void CheckHeights()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position, -transform.up, out hit, 110, mask))
        {
            playerLookAt.transform.position = hit.point;
        }
    }
}
