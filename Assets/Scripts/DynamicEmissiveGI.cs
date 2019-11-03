using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class DynamicEmissiveGI : MonoBehaviour
{
    new Renderer renderer;

    void Awake()
    {
        renderer = GetComponent<Renderer>();
    }

    void Start()
    {
        renderer.material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;
    }

    void Update()
    {
    }
}