Shader "Pix2Pix/SelectionControl"
{
    Properties
    {
        _Sensor ("Input sensor", 2D) = "black" {}
        _Buffer ("Buffer", 2D) = "black" {}
        _MaxDist ("Max Distance", Float) = 0.02
    }
    SubShader
    {
        Tags { "Queue"="Overlay+1" "ForceNoShadowCasting"="True" "IgnoreProjector"="True" }
        ZWrite Off
        ZTest Always
        Cull Off
        
        Pass
        {
            Lighting Off
            SeparateSpecular Off
            Fog { Mode Off }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "Pix2PixLayout.cginc"

            static const float2 exTable[8] =
            {
                0.0, 0.0,
                1.0, 0.0,
                2.0, 0.0,
                3.0, 0.0,
                0.0, 1.0,
                1.0, 1.0,
                2.0, 1.0,
                3.0, 1.0
            };

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float4> _Buffer;
            Texture2D<float> _Sensor;
            float4 _Buffer_TexelSize;
            float _MaxDist;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = float4(v.uv * 2 - 1, 0, 1);
                #ifdef UNITY_UV_STARTS_AT_TOP
                v.uv.y = 1-v.uv.y;
                #endif
                o.uv.xy = UnityStereoTransformScreenSpaceTex(v.uv);
                o.uv.z = (distance(_WorldSpaceCameraPos,
                    mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz) > _MaxDist ||
                    !unity_OrthoParams.w) ?
                    -1 : 1;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                clip(i.uv.z);
                uint2 px = _Buffer_TexelSize.zw * i.uv.xy;
                float4 col = 0.0;

                float4 curXYEdgeExample = LoadValue(_Buffer, uint2(0, 0));
                float4 edgeExampleTrans = LoadValue(_Buffer, uint2(0, 1));
                float4 clearEdgeExampleChange = LoadValue(_Buffer, uint2(1, 0));

                float2 prevEdgeExampleIndex = curXYEdgeExample.zw;

                float3 touchPosCount = 0.0;
                for (int i = 0; i < 128; i++) {
                    for (int j = 0; j < 128; j++) {
                        float di = _Sensor.Load(int3(i, j, 0)).r;
                        touchPosCount.xy += di > 0.15 ? float2(i, j) : 0..xx;
                        touchPosCount.z += di > 0.15 ? 1.0 : 0.0;
                    }
                }
                touchPosCount.xy = floor(touchPosCount.xy /
                            max(touchPosCount.z, 1.));
                touchPosCount.x = 128.0 - touchPosCount.x;

                curXYEdgeExample.xy = touchPosCount.xy;

                // Network selection
                if (insideArea(uint4(20, 100, 90, 15), curXYEdgeExample.xy)){
                    curXYEdgeExample.z = 0.0;
                }
                else if (insideArea(uint4(20, 85, 90, 15), curXYEdgeExample.xy)){
                    curXYEdgeExample.z = 1.0;
                }
                else if (insideArea(uint4(20, 71, 90, 15), curXYEdgeExample.xy)){
                    curXYEdgeExample.z = 2.0;
                }
                else if (insideArea(uint4(20, 56, 90, 15), curXYEdgeExample.xy)){
                    curXYEdgeExample.z = 3.0;
                }

                // Changed selection
                clearEdgeExampleChange.y = 
                    (prevEdgeExampleIndex.x != curXYEdgeExample.z) ? 1.0 : 0.0;

                // Transition
                edgeExampleTrans.x = edgeExampleTrans.x -
                    (edgeExampleTrans.x - curXYEdgeExample.z) * unity_DeltaTime * 10.0;

                // Example selection
                if (insideArea(uint4(28, 34, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 0.0;
                }
                else if (insideArea(uint4(46, 34, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 1.0;
                }
                else if (insideArea(uint4(64, 34, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 2.0;
                }
                else if (insideArea(uint4(82, 34, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 3.0;
                }
                else if (insideArea(uint4(28, 25, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 4.0;
                }
                else if (insideArea(uint4(46, 25, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 5.0;
                }
                else if (insideArea(uint4(64, 25, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 6.0;
                }
                else if (insideArea(uint4(82, 25, 18, 9), curXYEdgeExample.xy)){
                    curXYEdgeExample.w = 7.0;
                }

                // Changed selection
                clearEdgeExampleChange.z = 
                    (prevEdgeExampleIndex.y != curXYEdgeExample.w) ? 1.0 : 0.0;

                // Transition
                edgeExampleTrans.yz = edgeExampleTrans.yz -
                    (edgeExampleTrans.yz - exTable[floor(curXYEdgeExample.w)]) * unity_DeltaTime.xx * 10.0;

                // Clear
                if (insideArea(uint4(46, 8, 36, 12), curXYEdgeExample.xy)){
                    clearEdgeExampleChange.x = 1.0;
                }
                else {
                    clearEdgeExampleChange.x = 0.0;
                }

                StoreValue(px, curXYEdgeExample, col, uint2(0, 0));
                StoreValue(px, edgeExampleTrans, col, uint2(0, 1));
                StoreValue(px, clearEdgeExampleChange, col, uint2(1, 0));
                return col;
            }
            ENDCG
        }
    }
}
