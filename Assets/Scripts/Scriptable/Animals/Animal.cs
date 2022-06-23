using UnityEngine;
using UnityEngine.Animations;

[CreateAssetMenu(fileName = "Animal", menuName = "ScriptableObjects/Animal", order = 1)]
public class Animal : ScriptableObject
{
    public string _Name;
    
    public GameObject _PrefabAnimal;
    public RuntimeAnimatorController _Animator;
    public float _PVMax;
    public float _Degats;
    public float _Longevite;
    public float _VitesseMax;
    public Regime _Regime;
    public AnimationCurve _CourbeVitalite;
    public AnimationCurve _CourbeScale;
    

    public Material gigatisme;
    public Material enflame;
    public Material agressif;
    public Material empoisone;
    public Material normal;
    public Material beni;

    public AudioClip moveClip;
    public AudioClip DeathClip;
    public AudioClip AttackClip;

    public enum Regime
    {
        Carnivore,
        Herbivore,
        Lithophage,
    };
}