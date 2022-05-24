using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class AnimalNavMesh : MonoBehaviour
{
    [Header("Data")]
    public Animal Animal_Data;
    public TimeParam Time_Data;

    [Header("Personal Variables")]
    public float actualPV;
    public float age = 1f;
    public float anneeSpawn = 0;

    [Header("Object Reference")]
    public MeshFilter mesh;
    public GameObject vue;
    public GameObject contact;
    public GameObject destination;

    private NavMeshAgent agent;
    private float timeLeft;



    private void Awake()
    {
        RefreshPv();
        mesh.mesh = Animal_Data._Mesh;
        agent = GetComponent<NavMeshAgent>();
        agent.speed = Animal_Data._VitesseMax;
        timeLeft = 1;
    }

    private void Update()
    {
        RefreshPv();
        RefreshAge();
        RefreshSize();
        
    }

    void RefreshPv()
    {
        if(age < Animal_Data._Longevite)
        {
            
            actualPV = Animal_Data._PVMax * Animal_Data._CourbeVitalite.Evaluate(age / Animal_Data._Longevite);
        }
        else
        {
            Destroy(transform.gameObject);
        }
        
    }

    void RefreshSize()
    {
        Vector3 scale = Vector3.one * Animal_Data._CourbeScale.Evaluate(age / Animal_Data._Longevite);
        mesh.transform.localScale = Vector3.Lerp(mesh.transform.localScale, scale, Time.deltaTime);
    }

    public void RefreshAge()
    {
        age = Time_Data._Annee - anneeSpawn;
    }
    
    public void Movement()
    {
        agent.speed = Animal_Data._VitesseMax * Time_Data._SelectedSpeed;

        Vector3 destination = transform.position + (Random.insideUnitSphere * 20);
        destination.y = transform.position.y;


        timeLeft -= Time.deltaTime * Time_Data._SelectedSpeed;

        if (timeLeft < 0 && Time_Data._SelectedSpeed != 0)
        {
            
            timeLeft = Time_Data._RateAnnee;
            agent.SetDestination(destination);

        }
        
    }
}
