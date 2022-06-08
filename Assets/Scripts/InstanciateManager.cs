using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstanciateManager : MonoBehaviour
{
    public Animal potamouss;
    public Animal cerfeuil;
    public Animal lapillon;
    public Animal lomphore;
    public Animal raynodon;

    public TerrainParam paramTerrain;
    public GameObject prefabAnimal;

    public LayerMask mask;
    private GameObject obj;


    private void Update()
    {
        if (Input.GetMouseButtonDown(0) && !paramTerrain.isTerraforming && !paramTerrain.isSelectAnimal)
            SpawnAnimal();
    }

    public void SpawnAnimal()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, mask))
        {
            switch (paramTerrain.animalType)
            {

                case TerrainParam.AnimalType.Cerfeuil:
                    obj = Instantiate(prefabAnimal, hit.point, Quaternion.identity, GameObject.Find("Animals").transform);
                    obj.GetComponent<AnimalNavMesh>().Animal_Data = cerfeuil;
                    obj.GetComponent<AnimalNavMesh>().InitAnimal();
                    break;

                case TerrainParam.AnimalType.Lapillon:
                    obj = Instantiate(prefabAnimal, hit.point, Quaternion.identity, GameObject.Find("Animals").transform);
                    obj.GetComponent<AnimalNavMesh>().Animal_Data = lapillon;
                    obj.GetComponent<AnimalNavMesh>().InitAnimal();
                    break;

                case TerrainParam.AnimalType.Lomphore:
                    obj = Instantiate(prefabAnimal, hit.point, Quaternion.identity, GameObject.Find("Animals").transform);
                    obj.GetComponent<AnimalNavMesh>().Animal_Data = lomphore;
                    obj.GetComponent<AnimalNavMesh>().InitAnimal();
                    break;

                case TerrainParam.AnimalType.Potamouss:
                    obj = Instantiate(prefabAnimal, hit.point, Quaternion.identity, GameObject.Find("Animals").transform);
                    obj.GetComponent<AnimalNavMesh>().Animal_Data = potamouss;
                    obj.GetComponent<AnimalNavMesh>().InitAnimal();
                    break;

                case TerrainParam.AnimalType.Raynodon:
                    obj = Instantiate(prefabAnimal, hit.point, Quaternion.identity, GameObject.Find("Animals").transform);
                    obj.GetComponent<AnimalNavMesh>().Animal_Data = raynodon;
                    obj.GetComponent<AnimalNavMesh>().InitAnimal();
                    break;


            }
        }
            
    }
}
