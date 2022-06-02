using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColliderVueAnimal : MonoBehaviour
{
    private AnimalNavMesh scriptParent;

    private void Awake()
    {
        scriptParent = transform.parent.parent.GetComponent<AnimalNavMesh>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Animal"))
            scriptParent.vueList.Add(other.gameObject);
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Animal"))
            scriptParent.vueList.Remove(other.gameObject);
    }
}
