using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class JoystickCamera : MonoBehaviour
{
    [SerializeField]
    float sensitivityX = 8f;    
    float xRotation = 0f;


    [SerializeField] Transform playerCamera;    
    [SerializeField] float xClamp = 85f;
    [SerializeField] float minXClamp = 0f;

     
    public float camDistance;
    public LayerMask maskCam;
    public float lerpTime = 5f;
    public AnimationCurve curve;    
    public AnimationCurve camZoomCurve;    
    public Vector2 camDir;

    private GameObject player;

    private void Start()
    {
        playerCamera = transform.GetChild(0);
        player = GameObject.Find("Indicator");
    }

    private void Update()
    {
        CameraRotation();
        //playerCamera.transform.LookAt(transform);
    }
    
    private void FixedUpdate()
    {
        
        CameraColision();
        RotateCam();
        Zoom();

        Vector3 relativePos = player.transform.position - playerCamera.position;        
        Quaternion rotation = Quaternion.LookRotation(relativePos, Vector3.up);
        playerCamera.rotation = Quaternion.Lerp(playerCamera.rotation, rotation, curve.Evaluate(Time.deltaTime * lerpTime));

    }

    private float zoomValue = 50f;

    void Zoom()
    {
        player.transform.parent.GetComponent<Deplacement>().speed = 15 * (zoomValue/50);
        zoomValue = Mathf.Clamp(zoomValue, 1f, 50f);
        zoomValue = Mathf.Lerp(zoomValue, zoomValue + Input.GetAxis("Mouse ScrollWheel") * 20, curve.Evaluate(Time.deltaTime * 20));

        Debug.Log((zoomValue / 50));
        playerCamera.localPosition = new Vector3(playerCamera.localPosition.x, playerCamera.localPosition.y, Mathf.Lerp(playerCamera.localPosition.y, -Vector3.Distance(transform.position, player.transform.position), 1 - (zoomValue / 50)));

        //playerCamera.localPosition = new Vector3(playerCamera.localPosition.x, zoomValue, playerCamera.localPosition.z);

        /*if (playerCamera.localPosition.z >= -1)
            playerCamera.localPosition = new Vector3(playerCamera.localPosition.x, playerCamera.localPosition.y, -1.1f);*/
    }
    

    private void RotateCam()
    {        
        xRotation -= camDir.y;
        xRotation = Mathf.Clamp(xRotation, minXClamp, xClamp);
        Vector3 targetRotation = transform.localEulerAngles;
        targetRotation.x = xRotation;
        targetRotation.y += camDir.x * sensitivityX;
        targetRotation.z = 0;
        transform.localEulerAngles = targetRotation;
    }

    public void CameraRotation()
    {
        if (Input.GetMouseButton(1))
        {
            camDir = new Vector2(Input.GetAxisRaw("Mouse X"), Input.GetAxisRaw("Mouse Y"));
        }
        else
        {
            camDir = Vector2.zero;
        }        
    }
       

    void CameraColision()
    {
        RaycastHit hit;
        if(Physics.Raycast(transform.position, -transform.forward, out hit, camDistance, maskCam))
        {            
            playerCamera.position = hit.point + (playerCamera.forward * 3f);
        }        
    }
}
