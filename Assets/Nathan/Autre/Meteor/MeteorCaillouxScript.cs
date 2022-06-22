using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeteorCaillouxScript : MonoBehaviour
{
    public float speed;
    public GameObject impactPrefab;
    public GameObject startimpactPrefab;

    private Rigidbody rb;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        var startimpactVFX = Instantiate(startimpactPrefab, gameObject.transform.position, gameObject.transform.rotation) as GameObject;
        Destroy(startimpactVFX, 5);
    }

    private void FixedUpdate()
    {
    }

    private void OnCollisionEnter(Collision collision)
    {

        if (collision.gameObject.CompareTag("Animal"))
        {
            collision.gameObject.GetComponent<AnimalNavMesh>().statut = AnimalNavMesh.Statut.Enflame;
            speed = 0;

            ContactPoint contact = collision.contacts[0];
            Quaternion rot = Quaternion.FromToRotation(Vector3.up, contact.normal);
            Vector3 pos = contact.point;

            if (impactPrefab != null)
            {
                var impactVFX = Instantiate(impactPrefab, pos, rot) as GameObject;
                Destroy(impactVFX, 5);
            }
            gameObject.GetComponent<Rigidbody>().isKinematic = true;
            gameObject.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezePositionX;
            gameObject.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeRotationZ;
        }
        

    }
}
