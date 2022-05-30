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
        Move();
    }
    private void FixedUpdate()
    {
        
    }

    void Move()
    {
        Vector3 dest = (Input.GetAxis("Horizontal") * speed * transform.right) + (Input.GetAxis("Vertical") * speed * transform.forward);
        rb.AddForce(dest, ForceMode.Impulse);
        //rb.velocity = dest * Time.deltaTime * 100f;
        transform.position = new Vector3(Mathf.Clamp(transform.position.x, -400, 400), transform.position.y, Mathf.Clamp(transform.position.z, -400, 400)); 
        

    }

    void Rotation()
    {
        transform.localEulerAngles = new Vector3(0, cam.transform.localEulerAngles.y, 0);        
    }
}
