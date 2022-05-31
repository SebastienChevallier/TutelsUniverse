using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeManager : MonoBehaviour
{
    public TimeParam data_Time;    
    private float timeLeft;

    private void Start()
    {
        timeLeft = data_Time._RateAnnee;
    }

    void FixedUpdate()
    {
        timeLeft -= Time.deltaTime * data_Time._SelectedSpeed;        

        if(timeLeft < 0 && data_Time._SelectedSpeed != 0)
        {
            data_Time._Annee = data_Time._Annee + 1;
            timeLeft = data_Time._RateAnnee;
            
        }
    }
}
