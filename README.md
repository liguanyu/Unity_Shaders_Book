# shader_learning
《Unity Shader入门精要》跟敲



| 模型空间转换函数 | 功能描述 |
| ---------------- | -------- |
| ~~UnityObjectToWorldPos(pos)~~ | 返回把顶点坐标从模型空间转换到世界空间。使用`mul(unity_ObjectToWorld, v.vertex);` |
| UnityObjectToViewPos(pos) | 返回把顶点坐标从模型空间转换到观察空间。输入pos：三元坐标； |
| UnityObjectToClipPos(pos) | 返回把顶点坐标从模型空间转换到裁剪空间。输入pos：三元坐标； |
| UnityObjectToWorldDir(dir) | 返回把方向矢量从模型空间转换到世界空间。输入pos：三元向量； |
| UnityObjectToWorldNormal(nor) | 返回把法线矢量从模型空间转换到世界空间。输入pos：三元向量； |


| 世界空间转换函数 | 功能描述 |
| ---------------- | -------- |
| UnityWorldToViewPos(pos) | 返回把顶点坐标从世界空间转换到观察空间。输入pos：三元坐标； |
| UnityWorldToClipPos(pos) | 返回把顶点坐标从世界空间转换到裁剪空间。输入pos：三元坐标； |
| UnityWorldToObjectDir(dir) | 返回把方向矢量从世界空间转换到模型空间。输入pos：三元向量； |



| 观察空间转换函数 | 功能描述 |
| ---------------- | -------- |
| UnityViewToClipPos(pos) | 返回把顶点坐标从观察空间转换到裁剪空间。输入pos：三元向量； |


| 光照函数 | 功能描述 |
| -------- | -------- |
| ObjSpaceLightDir(v) | 返回模型空间中从该点到光源的光照方向。输入v：模型空间中的点；没有归一化。 |
| WorldSpaceLightDir(localPos) | 返回世界空间中从该点到光源的光照方向。输入localPos：模型空间中的点；没有归一化。 |
| UnityWorldSpaceLightDir(worldPos) | 返回世界空间中从该点到光源的光照方向。输入worldPos：世界空间中的点；没有归一化。 |



| 观察函数 | 功能描述 |
| -------- | -------- |
| ObjSpaceViewDir(v) | 返回模型空间中从该点到摄像机的观察方向。输入v：模型空间中的点；没有归一化。 |
| WorldSpaceViewDir(localPos) | 返回世界空间中从该点到摄像机的观察方向。输入localPos：模型空间中的点；没有归一化。 |
| UnityWorldSpaceViewDir(worldPos) | 返回世界空间中从该点到摄像机的观察方向。输入worldPos：世界空间中的点；没有归一化。 |



| 贴图函数 | 功能描述 |
| -------- | -------- |
| TRANSFORM_TEX(tex, name) | 返回模型顶点的uv和Tiling、Offset两个变量进行运算后值。tex：采样纹理；name：外置贴图； |
| UnpackNormal(packednormal) | 返回法线纹理查询。 |
