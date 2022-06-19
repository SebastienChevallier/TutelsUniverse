using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LancerMeteorScript : MonoBehaviour
{
    [SerializeField]
    private Transform Lancer;

    [SerializeField]
    private Rigidbody Meteor;

    private float MeteorSpeed;

    public float Crachat = 5f;
    public float stopCrachat = 500f;
    public bool stopCrachatBool;
    public GameObject BoomLancerPrefab;
    public float RandomLancer;

    private float randomDirectionModifierX,
        randomDirectionModifierY,
        randomDirectionModifierZ, randomSpeed;

    void Update()
    {
        Crachat -= Time.deltaTime;
        if (Crachat <= 0)
        {
            RandomLancer = Random.Range(20f, 30f);
            fireMeteor();
            Crachat += RandomLancer;
        }
        stopCrachat -= Time.deltaTime;
        if (stopCrachat <= 0)
        {
            stopCrachatBool = true;
        }
    }

    public void fireMeteor()
    {
        if (stopCrachatBool == false)
        {
            var newMeteor = Instantiate(Meteor, Lancer.position, Lancer.rotation);
            randomDirectionModifierX = Random.Range(-10f, 5f);
            randomDirectionModifierY = Random.Range(8f, 12f);
            randomDirectionModifierZ = Random.Range(-10f, 5f);
            randomSpeed = Random.Range(100f, 200f);
            newMeteor.AddRelativeForce(new Vector3(randomDirectionModifierX, randomDirectionModifierY, randomDirectionModifierZ) * randomSpeed);
        }
    }
}
