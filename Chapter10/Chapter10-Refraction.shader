Shader "Unity Shaders Book/Chapter 10/Refraction"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RefractColor ("Refract Color", Color) = (1, 1, 1, 1)
        _RefractAmount ("Refract Amount", Range(0, 1)) = 1
        _RefractRatio ("Refract Ratio", Range(0, 1)) = 0.5
        _Cubemap ("Refraction Cubemap", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        pass {
            Tags { "LightMode"="ForwardBase" } 

            CGPROGRAM

            // 让光照衰减等变量能够正确被赋值
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
            samplerCUBE _Cubemap;

            struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f 
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefr : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                // 求折射
                o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);

                TRANSFER_SHADOW(o);

                return o;
            }


            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

                fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount) * atten;

                return fixed4(color, 1.0);

            }

            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}
