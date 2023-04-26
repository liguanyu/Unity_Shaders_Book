// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 7/Single Texture" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "White" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }

    SubShader {
        Pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;     // 纹理的缩放xy与平移zw
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;    // 模型的第一组纹理
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 先用缩放属性_MainTex_ST.xy对顶点纹理坐标进行缩放，然后再使用偏移属性_MainTex_ST.zw进行偏移
                // 也可以直接 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // 阿贝多？
                // 用tex2D函数进行采样，用采样结果和颜色属性的乘积作为反射率
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                // 来自GPT
                // Unity中的胶囊体默认的UV坐标是按照球体的方式分布的，具体而言，它们遵循了所谓的“球形映射”（Spherical Mapping）方式，
                // 即将一个球体贴合到模型表面上，然后根据模型表面的曲率来计算每个点的UV坐标。

                // 在球形映射下，UV坐标的(0,0)点位于模型表面的最北端，即在胶囊体的顶部中心位置。
                // 而UV坐标的(1,1)点位于模型表面的最南端，即在胶囊体的底部中心位置。
                // 沿着胶囊体的纵向，UV坐标的V值（即纵向坐标）从0到1递增；
                // 而沿着胶囊体的横向，则根据经纬度分布不均匀，具体分布情况可以在Unity的文档中查看。

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir); 
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Specular"
}