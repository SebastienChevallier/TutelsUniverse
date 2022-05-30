using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class LoadSceneAsync : MonoBehaviour
{
    public Slider loadSlider;

    public void Start()
    {
        StartCoroutine(LoadYourAsyncScene(3));
        SceneManager.LoadScene(4, LoadSceneMode.Additive);
        
    }

    IEnumerator LoadYourAsyncScene(int sceneIndex)
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(sceneIndex, LoadSceneMode.Additive);

        /*if (asyncLoad.isDone)
        {
            SceneManager.UnloadSceneAsync("LoadSceneAsync");
        }*/

        // Wait until the asynchronous scene fully loads
        while (!asyncLoad.isDone)
        {
            loadSlider.value = asyncLoad.progress;

            yield return null;
        }
        SceneManager.UnloadSceneAsync("LoadSceneAsync");
    }
}
