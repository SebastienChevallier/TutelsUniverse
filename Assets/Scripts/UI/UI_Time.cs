using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_Time : MonoBehaviour
{
    public TimeParam timeParam;


    public void Pause()
    {
        timeParam._SelectedSpeed = timeParam._SpeedPause;
    }
    public void Play()
    {
        timeParam._SelectedSpeed = timeParam._SpeedNormal;
    }
    public void Rapide()
    {
        if(timeParam._SelectedSpeed != timeParam._SpeedX3)
        {
            timeParam._SelectedSpeed = timeParam._SpeedX3;
        }
        else
        {
            timeParam._SelectedSpeed = timeParam._SpeedNormal;
        }
            
    }
   
}
