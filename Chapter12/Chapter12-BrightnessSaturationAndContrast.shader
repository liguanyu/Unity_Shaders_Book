Shader "Unity Shaders Book/Chapter 12/Brightness Saturation and Contrast"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Brightness ("Brightness", Float) = 1
        _Saturation ("Saturation", Float) = 1
        _Contrast ("Contrast", Float) = 1
    }
    SubShader
    {
        pass
        {
            // Tags { "LightMode"="ForwardBase" }
            // 用于屏幕后处理，避免在不透明物体渲染完后调用OnImageRender()后，把所有的透明pass渲染挡住
            ZTest Always
            Cull off
            ZWrite off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Saturation;
            float _Contrast;

            // 位于 Unity/Editor/Data/CGIncludes/UnityCG.cginc
            // struct appdata_img
            // {
            //     float4 vertex : POSITION;
            //     half2 texcoord : TEXCOORD0;
            //     UNITY_VERTEX_INPUT_INSTANCE_ID
            // };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };


            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 renderTex  = tex2D(_MainTex, i.uv);
                fixed3 finalColor = renderTex.rgb * _Brightness;

                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                // 亮度值
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                finalColor = lerp(luminanceColor, finalColor, _Saturation);


                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, renderTex.a);
            }


            ENDCG
        }
    }
    // 关闭
    FallBack off
}
