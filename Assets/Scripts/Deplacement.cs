using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Deplacement : MonoBehaviour
{
    public float speed = 2f;
    private GameObject cam;
    private Rigidbody rb;
    private void Start()
    {
        cam = GameObject.Find("CamAnchor");
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {        
        Rotation();
    }
    private void FixedUpdate()
    {
        Move();
    }

    void Move()
    {
        Vector3 dest = (Input.GetAxis("Horizontal") * speed * transform.right) + (Input.GetAxis("Vertical") * speed * transform.forward);
        rb.velocity = dest;
        
        if (transform.position.x >= 401)
        {
            transform.position = new Vector3(400, transform.position.y, transform.position.z);
        }
        if (transform.position.x <= -401)
        {
            transform.position = new Vector3(-400, transform.position.y, transform.position.z);
        }

        if (transform.position.z >= 401)
        {
            transform.position = new Vector3(transform.position.x, transform.position.y, 400);
        }
        if (transform.position.z <= -401)
        {
            transform.position = new Vector3(transform.position.x, transform.position.y, -400);
        }

    }

    void Rotation()
    {
        transform.localEulerAngles = new Vector3(0, cam.transform.localEulerAngles.y, 0);
        
    }
}
