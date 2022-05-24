using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainModifier : MonoBehaviour
{
    public Terrain terrain;

    [Range(0.01f, 3f)]
    public float strenght = 0.01f;

    private TerrainData terrainData;
    private int heightResolution;
    private float[,] heights;


    // Start is called before the first frame update
    void Start()
    {
        terrainData = terrain.terrainData;
        heightResolution = terrainData.heightmapResolution;        
        heights = terrainData.GetHeights(0, 0, heightResolution, heightResolution);
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);



        if (Input.GetMouseButton(0))
        {
            if(Physics.Raycast(ray, out hit))
            {                
                RaiseTerrain(hit.point);
            }
        }
    }

    public void RaiseTerrain(Vector3 point)
    {
        float mouseX = (point.x  / terrainData.size.x);
        float mouseZ = (point.z  / terrainData.size.z);
        Debug.Log(mouseX + " ; " + mouseZ);  
        int coordX = (int)(mouseX * heightResolution);
        int coordZ = (int)(mouseZ * heightResolution);
        Debug.Log(mouseX + " ; " + mouseZ);


        float[,] modifiedHeights = new float[1, 1];
        float y = heights[coordX, coordZ];
        y += strenght * Time.deltaTime;

        if(y > terrainData.size.y)
        {
            y = terrainData.size.y;
        }

        modifiedHeights[0, 0] = y;
        
        heights[coordX, coordZ] = y;
        terrainData.SetHeights(coordX, coordZ, modifiedHeights);

    }


}

