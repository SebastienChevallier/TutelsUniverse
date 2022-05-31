using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Veget_SO", menuName = "ScriptableObjects/Veget_SO", order = 1)]
public class Veget_SO : ScriptableObject
{
    public string Name;
    public GameObject Mesh_1;
    public GameObject Mesh_2;
    public GameObject Mesh_3;
    public int Longévité;
    public AnimationCurve _CourbeVitalite;
    public AnimationCurve _CourbeScale;
}
