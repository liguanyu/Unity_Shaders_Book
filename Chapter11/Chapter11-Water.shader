Shader "Unity Shaders Book/Chapter 11/Image Sequence Animation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Time Sequence", 2D) = "white" {}
        _Magnitude ("Distortion Magnitude", Float) = 1
        _Frequency ("Vertical Frequency", Float) = 1
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
        _Speed ("Speed", Float) = 0.5
    }

    SubShader
    {
        // 顶点动画关闭批处理，因为会丢失各自的模型空间
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}

        Pass {
            Tags {"LightMode"="ForwardBase"}

            // 因为动画纹理往往很多透明部分，要开启混合
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            // 关闭了剔除

            CGPROGRAM

            #pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
			    float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                
                float4 offset;
                offset.yzw = float3(0, 0, 0);
                offset.x = sin(_Frequency * _Time.y + 
                    v.vertex.x * _InvWaveLength + 
                    v.vertex.y * _InvWaveLength + 
                    v.vertex.z * _InvWaveLength) * _Magnitude;
                // x分量直接使图片拉宽
                // y分量几乎无意义（都是0）
                // z分量使沿z轴的x分量出现sin波浪形
                // time决定了相位变化的速度
                // _InvWaveLength决定了波长

                o.pos = UnityObjectToClipPos(v.vertex + offset);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv += float2(0, _Time.y * _Speed);

                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {

                fixed4 c = tex2D(_MainTex, i.uv);
                c.rgb *= _Color;

                return c;
            }

            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
