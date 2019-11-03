using System;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class LightsSmokeShaderController : MonoBehaviour
{
    [SerializeField] Renderer effectRenderer = default;
    [SerializeField] Vector2 center = default;
    [SerializeField, Range(0f, 2f)] float emissionIntensity = default;
    [SerializeField, Range(0, 10)] int numberOfLights = 3;
    [SerializeField] Texture2D backgroundTexture = default;
    [SerializeField] Color[] lightColors = new Color[3];
    [SerializeField, Range(0f, 2f)] float[] intensities = new float[3];
    [SerializeField, Range(-0.5f, 0.5f)] float[] radiuses = new float[3];
    [SerializeField, Range(-20f, 20f)] float[] angularSpeeds = new float[3];

    const int maxArraySize = 10;

    void OnValidate()
    {
        Array.Resize(ref lightColors, numberOfLights);
        Array.Resize(ref intensities, numberOfLights);
        Array.Resize(ref radiuses, numberOfLights);
        Array.Resize(ref angularSpeeds, numberOfLights);

        Color[] newLightColors = new Color[maxArraySize];
        float[] newIntensities = new float[maxArraySize];
        float[] newRadiuses = new float[maxArraySize];
        float[] newAngularSpeeds = new float[maxArraySize];

        for (int i = 0; i < numberOfLights; i++)
        {
            newLightColors[i] = lightColors[i];
            newIntensities[i] = intensities[i];
            newRadiuses[i] = radiuses[i];
            newAngularSpeeds[i] = angularSpeeds[i];
        }

        effectRenderer.sharedMaterial.SetTexture("_BackgroundTexture", backgroundTexture);
        effectRenderer.sharedMaterial.SetVector("_Center", center);
        effectRenderer.sharedMaterial.SetFloat("_EmissionIntensity", emissionIntensity);
        effectRenderer.sharedMaterial.SetInt("_NumberOfLights", numberOfLights);
        effectRenderer.sharedMaterial.SetColorArray("_LightColors", newLightColors);
        effectRenderer.sharedMaterial.SetFloatArray("_Intensities", newIntensities);
        effectRenderer.sharedMaterial.SetFloatArray("_Radiuses", newRadiuses);
        effectRenderer.sharedMaterial.SetFloatArray("_AngularSpeeds", newAngularSpeeds);
    }
}