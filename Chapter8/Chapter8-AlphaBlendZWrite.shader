Shader "Unity Shaders Book/Chapter 8/Alpha Blend ZWrite" 
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        // 防止透明度排序错误
        // ZWrite On：启用深度写入，将透明物体的深度值写入深度缓冲区。
        // ColorMask 0：禁用颜色写入，这样透明物体的颜色信息就不会被渲染到帧缓冲区。这个设置是为了确保这个Pass只影响深度缓冲区，而不影响最终的颜色输出。
        Pass {
            ZWrite On
            ColorMask 0
        }
        
        Pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET 
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Alpha test
                // 当texColor.a小于_Cutoff的时候，舍弃这个片元
                // clip(texColor.a - _Cutoff);
                // 等同于
                // if((texColor.a - _Cutoff) < 0.0)
                // {
                //     discard;
                // }

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                // 主要是改了下面的行
                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);

            }

            ENDCG
        }
    }

    // 此处也修改了
    FallBack "Diffuse"
}
