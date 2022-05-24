using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "TimeParam", menuName = "ScriptableObjects/TimeParam", order = 1)]
public class TimeParam : ScriptableObject
{
    public float _SelectedSpeed;
    public float _SpeedPause;
    public float _SpeedNormal;
    public float _SpeedX2;
    public float _SpeedX3;

    public float _RateAnnee;

    public float _Annee;
}
