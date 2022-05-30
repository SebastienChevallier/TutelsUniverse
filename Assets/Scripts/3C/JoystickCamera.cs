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

    private float zoomValue = -50f;

    void Zoom()
    {
        zoomValue += Input.GetAxis("Mouse ScrollWheel") * 20;
        playerCamera.localPosition = new Vector3(playerCamera.localPosition.x, playerCamera.localPosition.y , zoomValue );
        if (playerCamera.localPosition.z >= -1)
            playerCamera.localPosition = new Vector3(playerCamera.localPosition.x, playerCamera.localPosition.y, -1.1f);
    }
    

    private void RotateCam()
    {        
        xRotation += camDir.y;
        xRotation = Mathf.Clamp(xRotation, minXClamp, xClamp);
        Vector3 targetRotation = transform.localEulerAngles;
        targetRotation.x = xRotation;
        targetRotation.y -= camDir.x * sensitivityX;
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
