using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

/*
 * 伙伴模型屏幕泛光后处理脚本 add by yangfan 2022-6-17
 */
 [RequireComponent(typeof(Camera))]
public class PartnerBloom : MonoBehaviour
{
    [Header("是否启用")]
    public bool enabled = true;

    [Header("渲染摄像机")]
    public Camera renderingCamera;

    [Header("泛光颜色")]
    public Color bloomColor = Color.white;

    [Header("泛光强度")]
    [Range(0, 1)]
    public float blurFactor = 0.225f;

    [Header("泛光亮度")]
    [Range(0, 1)]
    public float brightnessFactor = 0.15f;

    //[Header("边缘光强度")]
    //[Range(0, 1)]
    //public float dimLightFactor = 0.5f;

    //[Header("泛光亮度")]
    //[HideInInspector]
    //[Range(0,1)]
    //public float luminanceThreshold = 0.2f;

    [Header("泛光延展范围,（值越小越影响性能）")]
    [Range(2, 15)]
    public int downSample = 4;

    [Header("高斯模糊范围")]
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.2f;

    [Header("高斯模糊次数,（值越大越影响性能）")]
    [Range(0,20)]
    public int blurTimes = 2;

    public Shader bloomShader;

    public Material bloomMat;

    private int camWid = 0;

    private int camHei = 0;

    private void Awake()
    {
        if (renderingCamera == null)
        {
            renderingCamera = this.GetComponent<Camera>();
        }
        camWid = renderingCamera.pixelWidth;
        camHei = renderingCamera.pixelHeight;
    }

    private void Start()
    {
        if (bloomShader == null) { return; }
        bloomMat = new Material(bloomShader);
    }

    private void OnDestroy()
    {
        Material.Destroy(bloomMat);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!enabled || renderingCamera == null || bloomMat == null || blurTimes <= 0)
        {
            Graphics.Blit(source,destination);
            return;
        }
        Bloomscheme1(source, destination);
    }

    private void Bloomscheme1(RenderTexture source, RenderTexture destination)
    {
        //
        bloomMat.SetColor("_BloomColor", bloomColor);
        //bloomMat.SetFloat("_LuminanceThreshold", 1 - luminanceThreshold);
        //
        RenderTexture partnerRT = RenderTexture.GetTemporary(source.width, source.height, 24);
        RenderTexture screenRT = RenderTexture.GetTemporary(source.width, source.height);
        //
        Graphics.SetRenderTarget(partnerRT.colorBuffer, source.depthBuffer);
        //
        GL.Clear(false, true, new Color(0,0,0,0));
        //
        Graphics.Blit(source, bloomMat, 0);
        //
        int rW = (int)(source.width / downSample);
        int rH = (int)(source.height / downSample);
        //
        RenderTexture bluredTex = RenderTexture.GetTemporary(rW, rH);
        //
        Graphics.Blit(source, bluredTex);
        //
        for (int i = 0; i < blurTimes; i++)
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(rW, rH);
            RenderTexture buffer2 = RenderTexture.GetTemporary(rW, rH);
            bloomMat.SetFloat("_BlurSize", 1 + i * blurSpread);
            Graphics.Blit(bluredTex, buffer1, bloomMat, 2);
            Graphics.Blit(buffer1, buffer2, bloomMat, 3);
            //
            RenderTexture.ReleaseTemporary(bluredTex);
            bluredTex = RenderTexture.GetTemporary(rW,rH);
            //
            Graphics.Blit(buffer2, bluredTex);
            //
            RenderTexture.ReleaseTemporary(buffer1);
            RenderTexture.ReleaseTemporary(buffer2);
            //
            if (i < blurTimes - 1)
            {
                rW /= 2;
                rH /= 2;
            }
        }
        //提取亮度图
        RenderTexture brightnesTex = RenderTexture.GetTemporary(rW, rH);
        Graphics.Blit(bluredTex, brightnesTex, bloomMat, 1);
        //叠加亮度图
        //Graphics.Blit(source, screenRT);
        //Graphics.SetRenderTarget(screenRT.colorBuffer, source.depthBuffer);
        //bloomMat.SetTexture("_PartnerMask", partnerRT);
        //bloomMat.SetTexture("_CombiningTex", brightnesTex);
        //bloomMat.SetFloat("_CombiningFactor", dimLightFactor);
        //Graphics.Blit(source, bloomMat, 6);
        //叠加模糊图
        bloomMat.SetTexture("_PartnerMask", partnerRT);
        bloomMat.SetTexture("_CombiningTex", bluredTex);
        bloomMat.SetFloat("_CombiningFactor", blurFactor);
        Graphics.Blit(source, screenRT, bloomMat, 4);
        //叠加亮度图
        bloomMat.SetTexture("_PartnerMask", partnerRT);
        bloomMat.SetTexture("_CombiningTex", brightnesTex);
        bloomMat.SetFloat("_CombiningFactor", brightnessFactor);
        Graphics.Blit(screenRT, destination, bloomMat, 5);
        //
        RenderTexture.ReleaseTemporary(partnerRT);
        RenderTexture.ReleaseTemporary(screenRT);
        RenderTexture.ReleaseTemporary(brightnesTex);
        RenderTexture.ReleaseTemporary(bluredTex);

    }
}
