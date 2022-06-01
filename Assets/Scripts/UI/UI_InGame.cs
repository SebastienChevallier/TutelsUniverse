using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_InGame : MonoBehaviour
{
    public TerrainParam paramTerrain;    

    public Slider sliderTaille;
    public Slider sliderForce;

    private void Start()
    {
        sliderForce.value = paramTerrain.strength;
        sliderTaille.value = paramTerrain.areaOfEffectSize;
    }

    public void Terraforming()
    {
        paramTerrain.isTerraforming = true;
    }
    public void NotTerraforming()
    {
        paramTerrain.isTerraforming = false;
    }

    public void Potamouss()
    {
        paramTerrain.animalType = TerrainParam.AnimalType.Potamouss;
    }
    public void Cerfeuil()
    {
        paramTerrain.animalType = TerrainParam.AnimalType.Cerfeuil;
    }
    public void Lapillon()
    {
        paramTerrain.animalType = TerrainParam.AnimalType.Lapillon;
    }
    public void Lomphore()
    {
        paramTerrain.animalType = TerrainParam.AnimalType.Lomphore;
    }
    public void Raynodon()
    {
        paramTerrain.animalType = TerrainParam.AnimalType.Raynodon;
    }

    public void Raise()
    {
        paramTerrain.effectType = TerrainParam.EffectType.raise;
    }
    public void Lower()
    {
        paramTerrain.effectType = TerrainParam.EffectType.lower;
    }
    public void Smooth()
    {
        paramTerrain.effectType = TerrainParam.EffectType.smooth;
    }

    public void ChangeTaille()
    {
        paramTerrain.SetSize((int)sliderTaille.value);
    }
    public void ChangeForce()
    {
        paramTerrain.SetStrength(sliderForce.value);
    }

    public void ChangeBrush(int nbBrush)
    {
        paramTerrain.brushSelection = nbBrush;
    }
}
