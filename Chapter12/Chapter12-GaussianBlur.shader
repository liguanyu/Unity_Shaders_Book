Shader "Unity Shaders Book/Chapter 12/Gaussian Blur"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        // 是贴图 _MainTex 的纹素尺寸大小，值： Vector4(1 / width, 1 / height, width, height)
        half4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;
        };

        v2f vertBlurVertival(appdata_img v)
        {
            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            return o;
        }

        v2f vertBlurHorizontal(appdata_img v)
        {
            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;

            o.uv[0] = uv;
            // x轴
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
            o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
            return o;
        }

        fixed4 fragBlur(v2f i) : SV_TARGET
        {
            float weight[3] = {0.4026, 0.2442, 0.0545};

            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

            for(int it=1; it < 3; it++)
            {
                sum += tex2D(_MainTex, i.uv[it * 2 - 1]).rgb * weight[it];
                sum += tex2D(_MainTex, i.uv[it * 2]).rgb * weight[it];
            }

            return fixed4(sum, 1.0);
        }

        ENDCG


        ZTest Always
        Cull off
        ZWrite off

        pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"
            CGPROGRAM

            #pragma vertex vertBlurVertival
            #pragma fragment fragBlur
            
            ENDCG
        }
        pass
        {
            NAME "GAUSSIAN_BLUR_HONRIZONTAL"
            CGPROGRAM

            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur
            
            ENDCG
        }
    }
    // 关闭
    FallBack off
}
