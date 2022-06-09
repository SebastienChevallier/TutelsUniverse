using UnityEngine;

[CreateAssetMenu(fileName = "Animal", menuName = "ScriptableObjects/Animal", order = 1)]
public class Animal : ScriptableObject
{
    public string _Name;
    public Mesh _Mesh;
    public GameObject _PrefabAnimal;
    public Material _Material;
    public float _PVMax;
    public float _Degats;
    public float _Longevite;
    public float _VitesseMax;
    public Regime _Regime;
    public AnimationCurve _CourbeVitalite;
    public AnimationCurve _CourbeScale;

    public enum Regime
    {
        Carnivore,
        Herbivore,
        Lithophage,
    };
}