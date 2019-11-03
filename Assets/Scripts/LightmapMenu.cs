using UnityEngine;
using UnityEditor;

public class LightmapMenu : MonoBehaviour
{
   [MenuItem ("Custom Bake/Bake Custom Emissives")]
   static void Bake()
   {
       GameObject[] emissiveObjects = GameObject.FindGameObjectsWithTag("CustomEmissive");

       foreach (GameObject emissiveObject in emissiveObjects)
       {
           Material material = emissiveObject.GetComponent<Renderer>().sharedMaterial;

           material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
       }
       
       Lightmapping.Bake ();
   }
}