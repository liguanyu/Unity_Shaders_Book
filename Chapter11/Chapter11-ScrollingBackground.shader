Shader "Unity Shaders Book/Chapter 11/Scrolling Background"
{
    Properties
    {
        _MainTex ("Base Layer", 2D) = "white" {}
        _DetailTex ("2nd Layer", 2D) = "white" {}
        _ScrollX ("Base Layer Scroll Speed", Float) = 1.0
        _Scroll2X ("2nd Layer Scroll Speed", Float) = 1.0
        _Multiplier ("Layer Multiplier", Float) = 1
    }
    SubShader
    {
        // Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        // 不考虑透明

        Pass {
            Tags {"LightMode"="ForwardBase"}

            // 因为动画纹理往往很多透明部分，要开启混合
            // ZWrite Off
            // Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;

            struct a2v
            {
                float4 vertex : POSITION;
			    float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
			    float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // frac获得小数部分
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);

                fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
                c.rgb *= _Multiplier;

                return c;
            }

            ENDCG
        }
    }
    FallBack "VertexLit"
}
