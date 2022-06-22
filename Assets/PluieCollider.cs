using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.VisualScripting;

public class PluieCollider : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Animal"))
        {
            other.gameObject.GetComponent<AnimalNavMesh>().statut = AnimalNavMesh.Statut.Passif;
        }

        if (other.CompareTag("Graine_1") || other.CompareTag("Graine_2") || other.CompareTag("Graine_3") || other.CompareTag("Graine_4"))
        {
            Variables.Object(other).Set("Age_Max", ((int)Variables.Object(other).Get("Age_Max")) / 2);
        }
    }
}
