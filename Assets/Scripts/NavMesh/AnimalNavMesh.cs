using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class AnimalNavMesh : MonoBehaviour
{
    [Header("Data")]
    public Animal Animal_Data;

    [Header("Personal Variables")]
    public float actualPV;
    public float age = 1f;

    [Header("Object Reference")]
    public MeshFilter mesh;
    public GameObject vue;
    public GameObject contact;
    public GameObject destination;

    private NavMeshAgent agent;
    


    private void Awake()
    {
        RefreshPv();
        mesh.mesh = Animal_Data._Mesh;
        agent = GetComponent<NavMeshAgent>();
        agent.speed = Animal_Data._VitesseMax;
    }

    private void Update()
    {
        RefreshPv();
        Movement(destination.transform.position);
    }

    void RefreshPv()
    {
        actualPV = Animal_Data._CourbeVitalite.Evaluate(age);
    }

    public void RefreshAge()
    {
        //Incrementation de l'age de la bete
    }

    void Movement(Vector3 dest)
    {
        
        agent.SetDestination(dest);
    }
}
