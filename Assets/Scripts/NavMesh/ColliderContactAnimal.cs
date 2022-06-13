using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColliderContactAnimal : MonoBehaviour
{
    private AnimalNavMesh scriptParent;

    private void Awake()
    {
        scriptParent = transform.parent.parent.GetComponent<AnimalNavMesh>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if ((other.CompareTag("Animal") || other.CompareTag("Graine_1") || other.CompareTag("Graine_2") || other.CompareTag("Graine_3") || other.CompareTag("Graine_4")) && !scriptParent.contactList.Contains(other.gameObject))
        {            
            scriptParent.contactList.Add(other.gameObject);

            if (other.GetComponent<AnimalNavMesh>().Animal_Data != scriptParent.Animal_Data )
            {
                scriptParent.animatorAnimal.SetBool("Fight", true);
            }

        }
    }

    private void OnTriggerExit(Collider other)
    {       
        if (other.CompareTag("Animal") || other.CompareTag("Graine_1") || other.CompareTag("Graine_2") || other.CompareTag("Graine_3") || other.CompareTag("Graine_4"))
        {
            scriptParent.contactList.Remove(other.gameObject);            
        }


    }
}
