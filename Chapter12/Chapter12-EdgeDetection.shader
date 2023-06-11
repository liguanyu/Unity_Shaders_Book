Shader "Unity Shaders Book/Chapter 12/Edge Detection"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
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
            #pragma fragment fragSobel
            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            // 是贴图 _MainTex 的纹素尺寸大小，值： Vector4(1 / width, 1 / height, width, height)
            uniform half4 _MainTex_TexelSize;
            float _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

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
                half2 uv[9] : TEXCOORD0;
            };


            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;

                // Texel纹素
                // 这里是计算出卷积计算时需要的9个纹理的坐标
                // 每个纹素的(1 / width, 1 / height, width, height)
                // 假如纹理是512*512
                // (1/512, 1/512, 512, 512)
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);

                return o;
            }

            fixed luminance(fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(v2f i)
            {
                // github源码和原书xy是反的, 但是效果好像没有区别
                const half Gx[9] = {-1, 0, 1,
                                    -2, 0, 2,
                                    -1, 0, 1};
                const half Gy[9] = {-1, -2, -1,
                                    0, 0, 0,
                                    1, 2, 1};



                half texColor;
                half edgeX = 0;
                half edgeY = 0;

                for(int it = 0; it < 9; it++)
                {
                    // 亮度值
                    texColor = luminance(tex2D(_MainTex, i.uv[it]));
                    // 卷积核x和y分别是梯度值
                    edgeX += texColor * Gx[it];
                    edgeY += texColor * Gy[it];
                }

                half edge = 1 - abs(edgeX) - abs(edgeY);

                return edge;
            }

            fixed4 fragSobel(v2f i) : SV_Target
            {
                // 可能小于0
                half edge = Sobel(i);

                // 越小越使用_EdgeColor
                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }



            ENDCG
        }
    }
    // 关闭
    FallBack off
}
