// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 11/Billboard"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1
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
            float _VerticalBillboarding;

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

                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                // 先把法线方向就是目视方向
                float3 normalDir = viewer - center;
                
                // 如果_VerticalBillboarding==1, 那么采用目视方向作为法线
                // 如果=0, 使用模式2, 向上向量始终固定, 那么说明法线的y分量始终为0
                normalDir.y = normalDir.y * _VerticalBillboarding;
                normalDir = normalize(normalDir);

                // up向量使用010, 但是为了避免法线也朝y轴引起平行叉乘错误
                // 在法线y分量为1时使用010
                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                // 再次更新up向量
                upDir = normalize(cross(normalDir, rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.pos = UnityObjectToClipPos(localPos);

                // 纹理
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

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
