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
        if(other.CompareTag("Animal") && !scriptParent.vueList.Contains(other.gameObject))
        {
            if (other.GetComponent<AnimalNavMesh>().Animal_Data != scriptParent.Animal_Data)
            {
                scriptParent.ennemisList.Add(other.gameObject);
            }
            else
            {
                scriptParent.vueList.Add(other.gameObject);
            }
            
        }
            
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Animal"))
        {   
            if (other.GetComponent<AnimalNavMesh>().Animal_Data != scriptParent.Animal_Data)
            {
                scriptParent.ennemisList.Remove(other.gameObject);
            }
            else
            {
                if (other.GetComponent<AnimalNavMesh>().isLeader && !scriptParent.isLeader)
                {
                    scriptParent.timeLeft = 0;
                }
                else
                {
                    scriptParent.vueList.Remove(other.gameObject);
                    //scriptParent.CheckLeader();
                }
            }
        }
        
    }
}
