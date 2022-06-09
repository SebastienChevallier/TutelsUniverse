using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;

public class UI_Menu : MonoBehaviour
{
    public ScriptableScene scene;
    public void Begin()
    {
        scene._SceneIndex = 6;
        SceneManager.LoadScene(2, LoadSceneMode.Additive);
        SceneManager.UnloadSceneAsync(1);
    }

    public void Play()
    {
        scene._SceneIndex = 2;
        SceneManager.LoadScene(2, LoadSceneMode.Additive);
        SceneManager.UnloadSceneAsync(1);
    }

    public void SceneAssets()
    {
        scene._SceneIndex = 5;
        SceneManager.LoadScene(2, LoadSceneMode.Additive);
        SceneManager.UnloadSceneAsync(1);
    }


}
