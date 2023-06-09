using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    // 边缘检测

    public Shader edgeDetectionShader;
    private Material gaussianBlurMaterial;

    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(edgeDetectionShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    [Range(0f, 1f)]
    public float edgesOnly = 0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
