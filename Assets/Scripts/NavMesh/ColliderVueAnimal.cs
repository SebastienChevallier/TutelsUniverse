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
        if (other.CompareTag("Graine_1") || other.CompareTag("Graine_2") || other.CompareTag("Graine_3") || other.CompareTag("Graine_4"))
        {
            scriptParent.vueList.Add(other.gameObject);
        }

        if((other.CompareTag("Animal")) && !scriptParent.vueList.Contains(other.gameObject))
        {
            if (other.GetComponent<AnimalNavMesh>().Animal_Data != scriptParent.Animal_Data && !scriptParent.ennemisList.Contains(other.gameObject))
            {
                scriptParent.ennemisList.Add(other.gameObject);
                
            }
            else
            {
                scriptParent.vueList.Add(other.gameObject);
            }
            
        }

        if(other.CompareTag("Foudre") && !scriptParent.vueList.Contains(other.gameObject))
        {
            scriptParent.ennemisList.Add(other.gameObject);
            scriptParent.animatorAnimal.SetTrigger("Fuite");
        }
            
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Foudre"))
        {
            scriptParent.ennemisList.Remove(other.gameObject);
        }

        if (other.CompareTag("Graine_1") || other.CompareTag("Graine_2") || other.CompareTag("Graine_3") || other.CompareTag("Graine_4"))
        {
            scriptParent.vueList.Remove(other.gameObject);
        }

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
