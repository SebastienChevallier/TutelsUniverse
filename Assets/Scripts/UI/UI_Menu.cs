using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;

public class UI_Menu : MonoBehaviour
{
    public void Play()
    {
        SceneManager.LoadScene(2, LoadSceneMode.Additive);
        SceneManager.UnloadSceneAsync(1);
    }

    public void SceneAssets()
    {
        SceneManager.LoadScene(5, LoadSceneMode.Additive);
        SceneManager.UnloadSceneAsync(1);
    }


}
