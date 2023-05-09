Shader "Unity Shaders Book/Chapter 10/Reflection"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;

            struct a2v 
            {
                float4 vertex : POSITION;
                float3 texcoord : TEXCOORD0;

            };
            
            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                // 翻转
                o.uv.x = 1 - o.uv.x;

                return o;
            }


            fixed4 frag(v2f i) : SV_TARGET
            {
                return tex2D(_MainTex, i.uv);

            }

            ENDCG
        }
    }
    // 还不是很明白这里
    FallBack Off
}
