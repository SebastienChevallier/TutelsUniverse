using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class Controller : MonoBehaviour
{
    public float _speed = 1f;

    private Rigidbody _Rigidbody;

    // Start is called before the first frame update
    void Start()
    {
        _Rigidbody = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        if (_Rigidbody.velocity.magnitude < _speed)
        {
            float value = Input.GetAxis("Vertical");
            if (value != 0)
                _Rigidbody.AddForce(0, 0, value * Time.fixedDeltaTime * 1000f);
        }
    }
}
