using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class Modifier : MonoBehaviour
{
    //place these where you would normally declare variables
    public Terrain targetTerrain; //The terrain obj you want to edit
    float[,] terrainHeightMap;  //a 2d array of floats to store 
    int terrainHeightMapWidth; //Used to calculate click position
    int terrainHeightMapHeight;
    float[,] heights; //a variable to store the new heights
    TerrainData targetTerrainData; // stores the terrains terrain data
    public enum EffectType
    {
        raise,
        lower,
        flatten,
        smooth,        
    };

    public Texture2D[] brushIMG; // This will allow you to switch brushes
    float[,] brush; // this stores the brush.png pixel data
    public int brushSelection; // current selected brush
    public int areaOfEffectSize = 100; // size of the brush
    [Range(0.01f, 10f)] // you can remove this if you want
    public float strength; // brush strength
    public float flattenHeight = 0; // the height to which the flatten mode will go
    public EffectType effectType;

    public TextureData textureData;
    public Material terrainMaterial;

    public GameObject decalPrefab;
    public Material decalMat;
    private GameObject decalProjector;

    void Awake()
    {
        brush = GenerateBrush(brushIMG[brushSelection], areaOfEffectSize); // This will take the brush image from our array and will resize it to the area of effect
        targetTerrain = FindObjectOfType<Terrain>(); // this will find terrain in your scene, alternatively, if you know you will only have one terrain, you can make it a public variable and assign it that way
    }

    private void Start()
    {
        decalProjector = Instantiate(decalPrefab, transform.position, Quaternion.identity);
        decalMat = decalProjector.transform.GetChild(0).GetComponent<DecalProjector>().material;
    }

    void Update()
    {
        SetBrushSize(areaOfEffectSize);
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Input.GetMouseButton(0))
        {       
            if (Physics.Raycast(ray, out hit, 100f))
            {                
                targetTerrain = GetTerrainAtObject(hit.transform.gameObject);
                SetEditValues(targetTerrain);
                GetTerrainCoordinates(hit, out int terX, out int terZ);
                ModifyTerrain(terX, terZ);
            }
        }

        if (Input.GetMouseButtonUp(0))
        {
            
            //textureData.UpdateMeshHeights(terrainMaterial, 0, 100);
            textureData.ApplyToMaterial(terrainMaterial);
        }

        if (Physics.Raycast(ray, out hit, 100f))
        {
            decalProjector.SetActive(true);
            _gpu_scale(brushIMG[brushSelection], areaOfEffectSize, areaOfEffectSize, FilterMode.Trilinear);
            decalProjector.transform.position = hit.point;
            //decalProjector.transform.localScale = new Vector3(areaOfEffectSize , areaOfEffectSize , areaOfEffectSize );
            Texture2D tempTex = brushIMG[brushSelection];
            //tempTex.alphaIsTransparency = true;
            tempTex.Apply();
            decalMat.SetTexture("Base_Map", tempTex);            
            decalProjector.transform.GetChild(0).GetComponent<DecalProjector>().size = new Vector3(areaOfEffectSize*1f, areaOfEffectSize*1f, areaOfEffectSize*1f);
        }
        else
        {
            decalProjector.SetActive(false);
        }
    }

    public Terrain GetTerrainAtObject(GameObject gameObject)
    {
        if (gameObject.GetComponent<Terrain>())
        {
            //This will return the Terrain component of an object (if present)
            return gameObject.GetComponent<Terrain>();
        }
        return default(Terrain);
    }

    public TerrainData GetCurrentTerrainData()
    {
        if (targetTerrain)
        {
            return targetTerrain.terrainData;
        }
        return default(TerrainData);
    }

    public Terrain GetCurrentTerrain()
    {
        if (targetTerrain)
        {
            return targetTerrain;
        }
        return default(Terrain);
    }

    public void SetEditValues(Terrain terrain)
    {
        targetTerrainData = GetCurrentTerrainData();
        terrainHeightMap = GetCurrentTerrainHeightMap();
        terrainHeightMapWidth = GetCurrentTerrainWidth();
        terrainHeightMapHeight = GetCurrentTerrainHeight();
    }

    private void GetTerrainCoordinates(RaycastHit hit, out int x, out int z)
    {
        int offset = areaOfEffectSize / 2; //This offsets the hit position to account for the size of the brush which gets drawn from the corner out
                                           //World Position Offset Coords, these can differ from the terrain coords if the terrain object is not at (0,0,0)
        Vector3 tempTerrainCoodinates = hit.point - hit.transform.position;
        //This takes the world coords and makes them relative to the terrain
        Vector3 terrainCoordinates = new Vector3(
            tempTerrainCoodinates.x / GetTerrainSize().x,
            tempTerrainCoodinates.y / GetTerrainSize().y,
            tempTerrainCoodinates.z / GetTerrainSize().z);
        // This will take the coords relative to the terrain and make them relative to the height map(which often has different dimensions)
        Vector3 locationInTerrain = new Vector3
            (
            terrainCoordinates.x * terrainHeightMapWidth,
            0,
            terrainCoordinates.z * terrainHeightMapHeight
            );
        //Finally, this will spit out the X Y values for use in other parts of the code
        x = (int)locationInTerrain.x - offset;
        z = (int)locationInTerrain.z - offset;
    }

    private float GetSurroundingHeights(float[,] height, int x, int z)
    {
        float value; // this will temporarily hold the value at each point
        float avg = height[x, z]; // we will add all the heights to this and divide by int num bellow to get the average height
        int num = 1;
        for (int i = 0; i < 4; i++) //this will loop us through the possible surrounding spots
        {
            try // This will try to run the code bellow, and if one of the coords is not on the terrain(ie we are at an edge) it will pass the exception to the Catch{} below
            {
                // These give us the values surrounding the point
                if (i == 0)
                { value = height[x + 1, z]; }
                else if (i == 1)
                { value = height[x - 1, z]; }
                else if (i == 2)
                { value = height[x, z + 1]; }
                else
                { value = height[x, z - 1]; }
                num++; // keeps track of how many iterations were successful  
                avg += value;
            }
            catch (System.Exception)
            {
            }
        }
        avg = avg / num;
        return avg;
    }

    public Vector3 GetTerrainSize()
    {
        if (targetTerrain)
        {
            return targetTerrain.terrainData.size;
        }
        return Vector3.zero;
    }

    public float[,] GetCurrentTerrainHeightMap()
    {
        if (targetTerrain)
        {
            // the first 2 0's indicate the coords where we start, the next values indicate how far we extend the area, so what we are saying here is I want the heights starting at the Origin and extending the entire width and height of the terrain
            return targetTerrain.terrainData.GetHeights(0, 0,
            targetTerrain.terrainData.heightmapResolution,
            targetTerrain.terrainData.heightmapResolution);
        }
        return default(float[,]);
    }

    public int GetCurrentTerrainWidth()
    {
        if (targetTerrain)
        {
            return targetTerrain.terrainData.heightmapResolution;
        }
        return 0;
    }
    public int GetCurrentTerrainHeight()
    {
        if (targetTerrain)
        {
            return targetTerrain.terrainData.heightmapResolution;
        }
        return 0;
        //test2.GetComponent<MeshRenderer>().material.mainTexture = texture;
    }

    public float[,] GenerateBrush(Texture2D texture, int size)
    {
        float[,] heightMap = new float[size, size];//creates a 2d array which will store our brush
        Texture2D scaledBrush = ResizeBrush(texture, size, size); // this calls a function which we will write next, and resizes the brush image
                                                                  //This will iterate over the entire re-scaled image and convert the pixel color into a value between 0 and 1
        for (int x = 0; x < size; x++)
        {
            for (int y = 0; y < size; y++)
            {
                Color pixelValue = scaledBrush.GetPixel(x, y);
                heightMap[x, y] = pixelValue.grayscale / 255;
            }
        }

        return heightMap;
    }

    public static Texture2D ResizeBrush(Texture2D src, int width, int height, FilterMode mode = FilterMode.Trilinear)
    {
        Rect texR = new Rect(0, 0, width, height);
        _gpu_scale(src, width, height, mode);
        //Get rendered data back to a new texture
        Texture2D result = new Texture2D(width, height, TextureFormat.ARGB32, true);
        result.Reinitialize(width, height);
        result.ReadPixels(texR, 0, 0, true);
        return result;
    }
    static void _gpu_scale(Texture2D src, int width, int height, FilterMode fmode)
    {
        //We need the source texture in VRAM because we render with it
        src.filterMode = fmode;
        src.Apply(true);
        //Using RTT for best quality and performance. Thanks, Unity 5
        RenderTexture rtt = new RenderTexture(width, height, 32);
        //Set the RTT in order to render to it
        Graphics.SetRenderTarget(rtt);
        //Setup 2D matrix in range 0..1, so nobody needs to care about sized
        GL.LoadPixelMatrix(0, 1, 1, 0);
        //Then clear & draw the texture to fill the entire RTT.
        GL.Clear(true, true, new Color(0, 0, 0, 0));
        Graphics.DrawTexture(new Rect(0, 0, 1, 1), src);
    }

    
    public void SetBrushSize(int value)//adds int value to brush size(make negative to shrink)
    {
        areaOfEffectSize = value;
        if (areaOfEffectSize > 200)
        { areaOfEffectSize = 200; }
        else if (areaOfEffectSize < 1)
        { areaOfEffectSize = 1; }
        brush = GenerateBrush(brushIMG[brushSelection], areaOfEffectSize); // regenerates the brush with new size
    }
    public void SetBrushStrength(float value)//same idea as SetBrushSize()
    {
        strength = value;
        if (strength > 1)
        { strength = 1; }
        else if (strength < 0.01f)
        { strength = 0.01f; }
    }
    public void SetBrush(int num)
    {
        brushSelection = num;
        brush = GenerateBrush(brushIMG[brushSelection], areaOfEffectSize);
        //RMC.SetIndicators();
    }

    void ModifyTerrain(int x, int z)
    {
        //These AreaOfEffectModifier variables below will help us if we are modifying terrain that goes over the edge, you will see in a bit that I use Xmod for the the z(or Y) values, which was because I did not realize at first that the terrain X and world X is not the same so I had to flip them around and was too lazy to correct the names, so don't get thrown off by that.
        int AOExMod = 0;
        int AOEzMod = 0;
        int AOExMod1 = 0;
        int AOEzMod1 = 0;
        if (x < 0) // if the brush goes off the negative end of the x axis we set the mod == to it to offset the edited area
        {
            AOExMod = x;
        }
        else if (x + areaOfEffectSize > terrainHeightMapWidth)// if the brush goes off the posative end of the x axis we set the mod == to this
        {
            AOExMod1 = x + areaOfEffectSize - terrainHeightMapWidth;
        }

        if (z < 0)//same as with x
        {
            AOEzMod = z;
        }
        else if (z + areaOfEffectSize > terrainHeightMapHeight)
        {
            AOEzMod1 = z + areaOfEffectSize - terrainHeightMapHeight;
        }
        
        heights = targetTerrainData.GetHeights(x - AOExMod, z - AOEzMod, areaOfEffectSize + AOExMod - AOExMod1, areaOfEffectSize + AOEzMod - AOEzMod1); // this grabs the heightmap values within the brushes area of effect
        
        ///Raise Terrain
        if (effectType == EffectType.raise)
        {
            for (int xx = 0; xx < areaOfEffectSize + AOEzMod - AOEzMod1; xx++)
            {
                for (int yy = 0; yy < areaOfEffectSize + AOExMod - AOExMod1; yy++)
                {
                    heights[xx, yy] += brush[xx - AOEzMod, yy - AOExMod] * strength; //for each point we raise the value  by the value of brush at the coords * the strength modifier
                }
            }
            targetTerrainData.SetHeights(x - AOExMod, z - AOEzMod, heights); // This bit of code will save the change to the Terrain data file, this means that the changes will persist out of play mode into the edit mode
        }
        ///Lower Terrain, just the reverse of raise terrain
        else if (effectType == EffectType.lower)
        {
            for (int xx = 0; xx < areaOfEffectSize + AOEzMod; xx++)
            {
                for (int yy = 0; yy < areaOfEffectSize + AOExMod; yy++)
                {
                    heights[xx, yy] -= brush[xx - AOEzMod, yy - AOExMod] * strength;
                }
            }
            targetTerrainData.SetHeights(x - AOExMod, z - AOEzMod, heights);
        }
        //this moves the current value towards our target value to flatten terrain
        else if (effectType == EffectType.flatten)
        {
            for (int xx = 0; xx < areaOfEffectSize + AOEzMod; xx++)
            {
                for (int yy = 0; yy < areaOfEffectSize + AOExMod; yy++)
                {
                    heights[xx, yy] = Mathf.MoveTowards(heights[xx, yy], flattenHeight / 600, brush[xx - AOEzMod, yy - AOExMod] * strength);
                }
            }
            targetTerrainData.SetHeights(x - AOExMod, z - AOEzMod, heights);
        }
        //Takes the average of surrounding points and moves the point towards that height
        else if (effectType == EffectType.smooth)
        {
            float[,] heightAvg = new float[heights.GetLength(0), heights.GetLength(1)];
            for (int xx = 0; xx < areaOfEffectSize + AOEzMod; xx++)
            {
                for (int yy = 0; yy < areaOfEffectSize + AOExMod; yy++)
                {
                    heightAvg[xx, yy] = GetSurroundingHeights(heights, xx, yy); // calculates the value we want each point to move towards
                }
            }
            for (int xx1 = 0; xx1 < areaOfEffectSize + AOEzMod; xx1++)
            {
                for (int yy1 = 0; yy1 < areaOfEffectSize + AOExMod; yy1++)
                {
                    heights[xx1, yy1] = Mathf.MoveTowards(heights[xx1, yy1], heightAvg[xx1, yy1], brush[xx1 - AOEzMod, yy1 - AOExMod] * strength); // moves the points towards their targets
                }
            }
            targetTerrainData.SetHeights(x - AOExMod, z - AOEzMod, heights);
        }       
    }

    public float SumArray(float[] toBeSummed)
    {
        float sum = 0;
        foreach (float item in toBeSummed)
        {
            sum += item;
        }
        return sum;
    }


}
