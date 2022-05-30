using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ParamTerrain", menuName = "ScriptableObjects/ParamTerrain", order = 1)]
public class TerrainParam : ScriptableObject
{
    public enum EffectType
    {
        raise,
        lower,        
        smooth,
    };

    public enum AnimalType
    {
        Potamouss,
        Lapillon,
        Cerfeuil,
        Raynodon,
        Lomphore,
    };

    public Texture2D[] brushIMG; // This will allow you to switch brushes
    
    public int brushSelection; // current selected brush
    public int areaOfEffectSize = 100; // size of the brush
    [Range(0.01f, 2f)] // you can remove this if you want
    public float strength; // brush strength
    public float flattenHeight = 0; // the height to which the flatten mode will go
    public EffectType effectType;
    public AnimalType animalType;
    public bool isTerraforming = true;

    public void SetSize(int size)
    {
        areaOfEffectSize = size;
    }

    public void SetStrength(float force)
    {
        strength = force;
    }
}
