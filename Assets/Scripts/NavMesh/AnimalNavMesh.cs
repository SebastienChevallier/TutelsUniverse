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
    public float foodGauge = 100;
    public float age = 1f;
    public float anneeSpawn = 0;
    public List<GameObject> vueList;
    public List<GameObject> contactList;

    [Header("Object Reference")]
    public MeshFilter mesh;
    public GameObject vue;
    public GameObject contact;

    public Animator animatorAnimal;
    private NavMeshAgent agent;
    private float timeLeft;
    private float timeFoodLeft;



    private void Awake()
    {
        RefreshPv();
        mesh.mesh = Animal_Data._Mesh;
        agent = GetComponent<NavMeshAgent>();
        animatorAnimal = GetComponent<Animator>();
        agent.speed = Animal_Data._VitesseMax;
        timeLeft = Random.Range(0f, 2f);
        anneeSpawn = Time_Data._Annee;
    }

    private void Update()
    {        
        RefreshPv();
        RefreshAge();
        RefreshSize();
        RefreshFood();
    }

    void RefreshFood()
    {
        timeFoodLeft -= Time.deltaTime * Time_Data._SelectedSpeed;

        if (timeFoodLeft < 0 && Time_Data._SelectedSpeed != 0)
        {
            timeFoodLeft = Time_Data._RateAnnee;
            foodGauge--;
            animatorAnimal.SetFloat("Food", foodGauge);
            if (foodGauge < 0)
            {
                Destroy(transform.gameObject);
            }
        }
    }

    void RefreshPv()
    {
        if(age < Animal_Data._Longevite)
        {
            
            actualPV = Animal_Data._PVMax * Animal_Data._CourbeVitalite.Evaluate(age / Animal_Data._Longevite);
            animatorAnimal.SetFloat("PV", actualPV);
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
        animatorAnimal.SetFloat("Age", age);
    }
    
    public void Movement()
    {
        agent.speed = Animal_Data._VitesseMax * Time_Data._SelectedSpeed;
        Vector3 destination = transform.position;

        if (vueList.Count > 0)
        {
            foreach(GameObject obj in vueList)
            {
                destination += obj.transform.position;
            }
            destination /= (vueList.Count + 1);
        }

        destination += (Random.insideUnitSphere * 10);
        destination.y = transform.position.y;


        timeLeft -= Time.deltaTime * Time_Data._SelectedSpeed;

        if (timeLeft < 0 && Time_Data._SelectedSpeed != 0)
        {
            
            timeLeft = Time_Data._RateAnnee - Random.Range(-2f, 2f);
            agent.SetDestination(destination);

        }
        
    }
}
