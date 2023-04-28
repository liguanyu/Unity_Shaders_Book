Shader "Unity Shaders Book/Chapter 7/Mask Texture" 
{
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "White" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}     // 法线纹理，记录的是法线空间中法线的扰动
        _BumpScale ("Bump Scale", Float) = 1.0
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        _SpecularScale ("Specular Scale", Float) = 1.0
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
            sampler2D _BumpMap;
            fixed4 _BumpMap_ST;     // 法线纹理的缩放xy与平移zw
            float _BumpScale;
            sampler2D _SpecularMask;
            fixed4 __SpecularMask_ST;     
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;    // 模型的第一组纹理
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET { 
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

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

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir); 

                // 由于提供的遮罩rgb分量相同，取了r
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Specular"
}
