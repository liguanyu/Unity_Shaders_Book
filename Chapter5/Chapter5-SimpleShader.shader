Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
    Properties {
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }

    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;

            struct a2v {
                // 模型空间顶点坐标
                float4 vertex : POSITION;
                // 模型空间法线
                float3 normal: NORMAL;
                // 模型第一套纹理坐标
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                // 裁剪空间坐标
                float4 pos : SV_POSITION;
                // y
                float3 color : COLOR0;
            };

            void vert(in a2v v,out v2f o) {
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
            }

            fixed4 frag(v2f i) : SV_TARGET{
                fixed3 c = i.color;
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }

            ENDCG
        }
    }
}