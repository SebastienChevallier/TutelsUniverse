using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Variable_Succes_Bouton : MonoBehaviour
{
    public Succes_SO succes_Data;
    public GameObject selectedSucces;

    private void Awake()
    {
        selectedSucces = GameObject.Find("Selected_Success_UI");
    }

    public void SetSucces_Data(Succes_SO data)
    {
        succes_Data = data;
    }
}
