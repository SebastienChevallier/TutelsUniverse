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
    
    [Header("Lerp Move")]
    public float lerpTime = 5f;
    public AnimationCurve curve;    
       
    
    [Header("Lerp Zoom")]
    public float ZoomTimeCam = 5f;
    public AnimationCurve camZoomCurve;

    [Header("Lerp CamDist")]
    public float lerpTimeCam = 5f;
    public AnimationCurve camDistCurve;

    [Header("Smooth Heights")]
    public float heightTimeCam = 5f;
    public AnimationCurve heightCurve;

    [Header("Smooth Cam Colision")]
    public float colisTimeCam = 5f;
    public AnimationCurve colisionCurve;

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
        ChangeAngleCam();
        if(CameraColision())
            Zoom();

        RotateCam();
        

        Vector3 relativePos = (player.transform.position + Vector3.up * 2f) - playerCamera.position;        
        Quaternion rotation = Quaternion.LookRotation(relativePos, Vector3.up);
        playerCamera.rotation = Quaternion.Lerp(playerCamera.rotation, rotation, curve.Evaluate(Time.deltaTime * lerpTime));
        
    }

    private float zoomValue = 50f;

    void Zoom()
    {
        player.transform.parent.GetComponent<Deplacement>().speed = 15 * (1-zoomValue/50)+3;
        zoomValue = Mathf.Clamp(zoomValue, 1f, 50f);
        zoomValue = Mathf.Lerp(zoomValue, zoomValue + Input.GetAxis("Mouse ScrollWheel") * 200, camZoomCurve.Evaluate(Time.deltaTime * ZoomTimeCam));

        
        //playerCamera.localPosition = new Vector3(playerCamera.localPosition.x, playerCamera.localPosition.y, Mathf.Lerp(playerCamera.localPosition.y, -Vector3.Distance(transform.position, player.transform.position), 1 - (zoomValue / 50)));

        Vector3 heigt = player.transform.parent.GetComponent<heightLevel>().CheckHeights();
        Vector3 camLocaPos = new Vector3(playerCamera.localPosition.x, playerCamera.localPosition.y, -(50 * camDistCurve.Evaluate(zoomValue / 50)));
        playerCamera.localPosition = Vector3.Lerp(playerCamera.localPosition, camLocaPos, camDistCurve.Evaluate(Time.deltaTime * lerpTimeCam));


        Vector3 pos = new Vector3(transform.position.x,100, transform.position.z);
        Vector3 finalPos = Vector3.Lerp(pos, heigt + Vector3.up * 2, (zoomValue / 50));
        transform.position = Vector3.Lerp(transform.position, finalPos, heightCurve.Evaluate(Time.deltaTime * heightTimeCam));
             
    }
    
    private void ChangeAngleCam()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if(zoomValue < 25)
            {
                zoomValue = 50f;
            }
            else
            {
                zoomValue = 1f;
            }
        }
    }

    private void RotateCam()
    {        
        xRotation -= camDir.y;
        zoomValue += camDir.y;
        xRotation = Mathf.Clamp(xRotation, minXClamp, xClamp);
        Vector3 targetRotation = transform.localEulerAngles;
        //targetRotation.x = xRotation;
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
       

    bool CameraColision()
    {
        RaycastHit hit;
        if(Physics.Raycast(transform.position, -transform.forward, out hit, (50 * camDistCurve.Evaluate(zoomValue / 50)), maskCam))
        {
            Vector3 pos = hit.point + playerCamera.forward * 5f;
            playerCamera.position = Vector3.Lerp(playerCamera.position, pos, colisionCurve.Evaluate(Time.deltaTime * colisTimeCam));
            return false;
        }
        return true;
    }
}
