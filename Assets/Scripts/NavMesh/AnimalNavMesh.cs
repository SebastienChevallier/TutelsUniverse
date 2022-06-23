using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using Unity.VisualScripting;

public class AnimalNavMesh : MonoBehaviour
{
    [Header("Data")]
    public Animal Animal_Data;
    public TimeParam Time_Data;

    [Header("Personal Variables")]
    public float actualPV;
    public float actualDmg;
    public float foodGauge = 100;
    public float age = 1f;
    public float anneeSpawn = 0;
    public bool isLeader = false;
    public GameObject cible;
    public Statut statut;

    [Header("Contact Lists")]
    public List<GameObject> vueList;
    public List<GameObject> contactList;
    public List<GameObject> ennemisList;

    [Header("FXs")]
    public GameObject gigantisme;
    public GameObject enflame;
    public GameObject beni;
    public GameObject empoisone;
    public GameObject agressif;

    [Header("Object Reference")]
    public SkinnedMeshRenderer mesh;
    public GameObject vue;
    public GameObject contact;
    public GameObject _PrefabMort;

    public Animator animatorAnimal;
    public Animator meshAnimator;

    public NavMeshAgent agent;
    public float timeLeft;
    private float timeFoodLeft;
    public GameObject animalPrefab;

    private float sizeMultiply;
    public AudioSource _audioSource;

    public enum Statut
    {
        Agressif,
        Passif,
        Enflame,
        Geant,
        Infected,
        Beni,
    };



    private void Awake()
    {
        InitAnimal();
        agent.updateRotation = false;

    }
    private void LateUpdate()
    {
        if (agent.velocity.sqrMagnitude > Mathf.Epsilon)
        {
            transform.rotation = Quaternion.LookRotation(agent.velocity.normalized);
        }        
    }

    private void Update()
    {
        CheckStatut();
        meshAnimator.SetFloat("Time", Time_Data._SelectedSpeed);
        CheckNavMesh();
        RefreshPv();
        RefreshAge();
        RefreshSize();
        RefreshFood();

        actualDmg = Mathf.Clamp(actualDmg, 0, Animal_Data._PVMax * Animal_Data._CourbeVitalite.Evaluate(age / Animal_Data._Longevite));
    }
    private float statutTime;

    public void CheckStatut()
    {
        statutTime -= Time.deltaTime * Time_Data._SelectedSpeed;
        if (statutTime < 0 && Time_Data._SelectedSpeed != 0)
        {
            switch (statut)
            {
                case Statut.Agressif:
                    setLeaderSize();

                    agressif.SetActive(true);
                    gigantisme.SetActive(false);
                    enflame.SetActive(false);
                    beni.SetActive(false);
                    empoisone.SetActive(false);

                    mesh.material = Animal_Data.agressif;

                    statutTime = 1f;
                    break;

                case Statut.Enflame:
                    setLeaderSize();

                    agressif.SetActive(false);
                    gigantisme.SetActive(false);
                    enflame.SetActive(true);
                    beni.SetActive(false);
                    empoisone.SetActive(false);

                    mesh.material = Animal_Data.enflame;

                    statutTime = 1f;
                    actualDmg += 2f;
                    break;

                case Statut.Geant:
                    statutTime = 1f;

                    agressif.SetActive(false);
                    gigantisme.SetActive(true);
                    enflame.SetActive(false);
                    beni.SetActive(false);
                    empoisone.SetActive(false);
                    mesh.material = Animal_Data.gigatisme;
                    sizeMultiply = 3;
                    break;

                case Statut.Infected:
                    setLeaderSize();

                    agressif.SetActive(false);
                    gigantisme.SetActive(false);
                    enflame.SetActive(false);
                    beni.SetActive(false);
                    empoisone.SetActive(true);
                    mesh.material = Animal_Data.empoisone;
                    statutTime = 1f;
                    actualDmg += 1f;
                    break;

                case Statut.Passif:
                    setLeaderSize();

                    agressif.SetActive(false);
                    gigantisme.SetActive(false);
                    enflame.SetActive(false);
                    beni.SetActive(false);
                    empoisone.SetActive(false);
                    mesh.material = Animal_Data.normal;
                    statutTime = 1f;
                    break;

                case Statut.Beni:
                    setLeaderSize();

                    agressif.SetActive(false);
                    gigantisme.SetActive(false);
                    enflame.SetActive(false);
                    beni.SetActive(true);
                    empoisone.SetActive(false);
                    mesh.material = Animal_Data.beni;
                    statutTime = 1f;
                    break;
            }
        }

        
    }

    public void CheckNavMesh()
    {
        if (!agent.isOnNavMesh)
        {
            Debug.Log("destroy");
            Destroy(transform.gameObject);
        }
    }

    public void CheckLeader()
    {
        if (vueList.Count > 0 && !isLeader)
        {
            foreach (GameObject obj in vueList)
            {
                if (obj.GetComponent<AnimalNavMesh>().isLeader)
                {
                    isLeader = false;
                }
                else
                {
                    isLeader = true;
                }
            }
        }
        else if (!isLeader)
        {
            isLeader = true;
        }
    }

    private GameObject _Mesh;

    public void InitAnimal()
    {
        RefreshPv();
        //mesh.mesh = Animal_Data._Mesh;
        _Mesh = Instantiate(Animal_Data._PrefabAnimal, transform.GetChild(0));
        _Mesh.name = Animal_Data._PrefabAnimal.name;
        _Mesh.transform.localPosition = Vector3.zero;

        _audioSource = GetComponent<AudioSource>();
        _audioSource.clip = Animal_Data.moveClip;

        agent = GetComponent<NavMeshAgent>();
        meshAnimator = _Mesh.transform.GetChild(0).GetComponent<Animator>();

        mesh = meshAnimator.gameObject.transform.GetChild(0).GetComponent<SkinnedMeshRenderer>();

        animatorAnimal = GetComponent<Animator>();
        //meshAnimator.runtimeAnimatorController = Animal_Data._Animator;

        
        agent.speed = Animal_Data._VitesseMax;
        timeLeft = Random.Range(0f, 2f);
        //mesh.gameObject.GetComponent<MeshRenderer>().material = Animal_Data._Material;
        anneeSpawn = Time_Data._Annee;
        //CheckLeader();
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
        if (age < Animal_Data._Longevite)
        {
            actualPV = Animal_Data._PVMax * Animal_Data._CourbeVitalite.Evaluate(age / Animal_Data._Longevite) - actualDmg;
            animatorAnimal.SetFloat("PV", actualPV);
        }
        else
        {
            Destroy(transform.gameObject);
        }

        if (actualPV < 0)
        {
            Destroy(transform.gameObject);
        }

    }

    public void Reproduction()
    {
        if (Animal_Data._CourbeVitalite.Evaluate(age / Animal_Data._Longevite) > 0.6f) 
        {
            foreach (GameObject obj in contactList)
            {
                if(obj.CompareTag("Animal") && obj.GetComponent<AnimalNavMesh>().Animal_Data == Animal_Data)
                {
                    animatorAnimal.SetBool("Reproduction", true);
                    GameObject enfant = Instantiate(animalPrefab, GameObject.Find("Animals").transform);
                    enfant.GetComponent<AnimalNavMesh>().Animal_Data = Animal_Data;
                    enfant.GetComponent<AnimalNavMesh>().InitAnimal();
                }
            }
        }
        animatorAnimal.SetBool("Reproduction", false);
    }

    public bool RechercheNouriture()
    {
        if (vueList != null)
        {
            foreach (GameObject obj in vueList)
            {
                if (obj.CompareTag("Graine_1") || obj.CompareTag("Graine_2") || obj.CompareTag("Graine_3") || obj.CompareTag("Graine_4"))
                {
                    agent.SetDestination(obj.transform.position);
                    return true;
                }
                return false;
            }
            return false;

        }
        return false;

    }

    public void Manger()
    {
        foreach (GameObject obj in contactList)
        {
            if ((obj.CompareTag("Graine_1") || obj.CompareTag("Graine_2") || obj.CompareTag("Graine_3") || obj.CompareTag("Graine_4")) && (bool)Variables.Object(obj).Get("Is_Fruit"))
            {
                foodGauge += 50f;
                meshAnimator.SetTrigger("Manger");
            }else if (Animal_Data._Regime == Animal.Regime.Carnivore && obj.CompareTag("Cadavre"))
            {
                foodGauge += 50f;
                meshAnimator.SetTrigger("Manger");
            }         
        }
        
    }

    void RefreshSize()
    {
        
        Vector3 scale = (Vector3.one * Animal_Data._CourbeScale.Evaluate(age / Animal_Data._Longevite));
        scale += Vector3.one * sizeMultiply * 3;
        _Mesh.transform.localScale = Vector3.Lerp(_Mesh.transform.localScale, scale, Time.deltaTime);
    }


    private void setLeaderSize()
    {
        if (isLeader)
        {
            sizeMultiply = 2f;
        }
        else
        {
            sizeMultiply = 1f;
        }
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
        _audioSource.PlayOneShot(Animal_Data.moveClip);

        if (vueList.Count > 0 && !isLeader)
        {

            foreach (GameObject obj in vueList)
            {
                if (obj.GetComponent<AnimalNavMesh>().isLeader)
                    destination = obj.transform.position;
            }
        }
        else
        {
            destination = transform.position;
        }

        destination += (Random.insideUnitSphere * 15);
        destination.y = transform.position.y;


        timeLeft -= Time.deltaTime * Time_Data._SelectedSpeed;

        if (timeLeft < 0 && Time_Data._SelectedSpeed != 0)
        {
            timeLeft = Time_Data._RateAnnee - Random.Range(-2f, Time_Data._RateAnnee);
            if (agent.isOnNavMesh)
            {
                agent.SetDestination(destination);
            }
            else
            {
                Destroy(transform);
            }

        }
    }


    public void Chasse()
    {
        if (ennemisList.Count > 0)
        {
            Vector3 destination = transform.position;
            destination = ennemisList[0].transform.position;
            cible = ennemisList[0];
            destination.y = transform.position.y;

            if (agent.isOnNavMesh)
            {
                agent.SetDestination(destination);
            }
        }
        else
        {
            cible = null;
            //statut = Statut.Passif;
        }
    }

    private float attTime;
    public void Attack()
    {
        if (cible != null && contactList.Contains(cible))
        {
            attTime -= Time.deltaTime * Time_Data._SelectedSpeed;
            if (attTime < 0 && Time_Data._SelectedSpeed != 0)
            {
                attTime = 0.5f;
                _audioSource.PlayOneShot(Animal_Data.AttackClip);
                cible.GetComponent<AnimalNavMesh>().actualDmg += Animal_Data._Degats;
            }
        }
        else
        {
            animatorAnimal.SetBool("Fight", false);
        }
    }

    public void Fuite()
    {
        agent.speed = Animal_Data._VitesseMax * Time_Data._SelectedSpeed * 1.5f;
        Vector3 destination = new Vector3(0, 0, 0);
        if (ennemisList.Count > 0)
        {
            foreach (GameObject obj in ennemisList)
            {
                destination += obj.transform.position;
            }

            destination /= ennemisList.Count;

            Vector3 newdestination = transform.position + ((transform.position - destination).normalized) * 5;
            newdestination.y = transform.position.y;


            agent.SetDestination(newdestination);
            //Debug.Log(newdestination);
        }

    }

    public bool CheckRace(GameObject animal)
    {
        if (animal.GetComponent<AnimalNavMesh>().Animal_Data._Regime == Animal.Regime.Carnivore)
        {
            ennemisList.Add(animal);
            return true;
        }
        return false;
    }


}