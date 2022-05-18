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
