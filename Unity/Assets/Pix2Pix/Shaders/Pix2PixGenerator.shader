Shader "Pix2Pix/Generator"
{
    Properties
    {
        _CamIn ("Cam Input", 2D) = "white" {}
        _Buffer ("Buffer", 2D) = "black" {}
        _Baked ("Baked Params", 2D) = "black" {}
        _Sensor ("Input sensor", 2D) = "black" {}
        _SelControl ("Selection Controller", 2D) = "black" {}
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
            
            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float4> _CamIn;
            Texture2D<float4> _Baked;
            Texture2D<float4> _SelControl;
            Texture2D<float> _Buffer;
            Texture2D<float> _Sensor;
            float4 _Buffer_TexelSize;
            float _MaxDist;
            uint bIndex;

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

            float frag (v2f i) : SV_Target
            {
                clip(i.uv.z);
                uint2 px = _Buffer_TexelSize.zw * i.uv.xy;
                float col = _Buffer.Load(uint3(px, 0)).x;

                // 4ms per layer
                float timer = LoadValue(_Buffer, txTimer);
                timer += unity_DeltaTime.x;

                if (timer < 0.004)
                {
                    StoreValue(txTimer, timer, col, px);
                    return col;
                }
                else timer = 0.0;

                // Touch registration
                float isHit = LoadValue(_Buffer, txUpdate);
                [branch]
                if (all(px == txUpdate))
                {
                    float t = 0.0;
                    for (uint i = 0; i < 128; i++) {
                        for (uint j = 0; j < 128; j++) {
                            t = max(_Sensor.Load(uint3(i, j, 0)).r, t);
                        }
                    }
                    
                    // Initial touch
                    if (isHit < 1.0) {
                        isHit = t > 0.3 ? 1.0 : 0.0;
                    }
                    // Still touching
                    else if (isHit < 2.0) { 
                        isHit = t > 0.3 ? 1.0 : 2.0;
                    }
                    // Stopped touching
                    else if (isHit < 3.0) { 
                        isHit = 0.0;
                    }
                    return isHit;
                }

                // Network selection
                float4 curXYEdgeExample = LoadValue(_SelControl, uint2(0, 0));
                float4 clearEdgeExampleChange = LoadValue(_SelControl, uint2(1, 0));
                bIndex = floor(curXYEdgeExample.z);

                // Layer counter
                // Do a forward pass whenever the network or an example is picked
                float lc = LoadValue(_Buffer, txLC);
                uint lcFloor = (isHit > 1.0 || clearEdgeExampleChange.y > 0.0 ||
                    clearEdgeExampleChange.z > 0.0) ? 0 : floor(lc);

                [branch]
                if (lcFloor == 1 && insideArea(txL1, px))
                {
                    // L1, kernel=4x4, stride=2, padding=1
                    px -= txL1.xy;
                    uint i = px.y % 128;
                    uint j = px.x % 128;
                    uint k = (px.x / 128) + (px.y / 128) * 8;

                    uint i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    float s = 0.0;
                    // kernel
                    for (uint l = 0; l < 3; l++) {
                        s +=
                            padOneGetImg(_CamIn, uint3(i0, j0, l), 255) * getWL1(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i0, j1, l), 255) * getWL1(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i0, j2, l), 255) * getWL1(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i0, j3, l), 255) * getWL1(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i1, j0, l), 255) * getWL1(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i1, j1, l), 255) * getWL1(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i1, j2, l), 255) * getWL1(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i1, j3, l), 255) * getWL1(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i2, j0, l), 255) * getWL1(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i2, j1, l), 255) * getWL1(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i2, j2, l), 255) * getWL1(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i2, j3, l), 255) * getWL1(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i3, j0, l), 255) * getWL1(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i3, j1, l), 255) * getWL1(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i3, j2, l), 255) * getWL1(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetImg(_CamIn, uint3(i3, j3, l), 255) * getWL1(_Baked, uint4(3, 3, l, k), bIndex);
                            // test(uint3(i0, j0, l), 255) * getWL1(_Baked, uint4(0, 0, l, k), bIndex) +
                            // test(uint3(i0, j1, l), 255) * getWL1(_Baked, uint4(0, 1, l, k), bIndex) +
                            // test(uint3(i0, j2, l), 255) * getWL1(_Baked, uint4(0, 2, l, k), bIndex) +
                            // test(uint3(i0, j3, l), 255) * getWL1(_Baked, uint4(0, 3, l, k), bIndex) +
                            // test(uint3(i1, j0, l), 255) * getWL1(_Baked, uint4(1, 0, l, k), bIndex) +
                            // test(uint3(i1, j1, l), 255) * getWL1(_Baked, uint4(1, 1, l, k), bIndex) +
                            // test(uint3(i1, j2, l), 255) * getWL1(_Baked, uint4(1, 2, l, k), bIndex) +
                            // test(uint3(i1, j3, l), 255) * getWL1(_Baked, uint4(1, 3, l, k), bIndex) +
                            // test(uint3(i2, j0, l), 255) * getWL1(_Baked, uint4(2, 0, l, k), bIndex) +
                            // test(uint3(i2, j1, l), 255) * getWL1(_Baked, uint4(2, 1, l, k), bIndex) +
                            // test(uint3(i2, j2, l), 255) * getWL1(_Baked, uint4(2, 2, l, k), bIndex) +
                            // test(uint3(i2, j3, l), 255) * getWL1(_Baked, uint4(2, 3, l, k), bIndex) +
                            // test(uint3(i3, j0, l), 255) * getWL1(_Baked, uint4(3, 0, l, k), bIndex) +
                            // test(uint3(i3, j1, l), 255) * getWL1(_Baked, uint4(3, 1, l, k), bIndex) +
                            // test(uint3(i3, j2, l), 255) * getWL1(_Baked, uint4(3, 2, l, k), bIndex) +
                            // test(uint3(i3, j3, l), 255) * getWL1(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL1, k, bIndex); // bias
                    s = leakyRELU(s, 0.2); // activation

                    col.r = s;
                }
                else if (lcFloor == 2 && insideArea(txL2, px))
                {
                    // L2, kernel=4x4, stride=2, padding=1
                    px -= txL2.xy;
                    uint i = px.y % 64;
                    uint j = px.x % 64;
                    uint k = (px.x / 64) + (px.y / 64) * 8;

                    uint i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    float s = 0.0;
                    // kernel
                    for (int l = 0; l < 64; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL1, uint3(i0, j0, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i0, j1, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i0, j2, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i0, j3, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j0, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j1, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j2, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j3, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j0, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j1, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j2, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j3, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j0, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j1, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j2, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j3, l), uint4(8, 8, 128, 128), 127) * getWL2(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL2, k, bIndex); // bias
                    s = leakyRELU(s, 0.2); // activation

                    col.r = s;
                }
                else if (lcFloor == 3 && insideArea(rmL2, px))
                {
                    // Mean
                    px -= rmL2.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 64; i++) {
                        for (int j = 0; j < 64; j++) {
                            s += getVal(_Buffer, txL2, uint3(i, j, l), uint4(8, 8, 64, 64));
                        }
                    }
                    s /= 4096.0;
                    col.r = s;
                }
                else if (lcFloor == 4 && insideArea(rvL2, px))
                {
                    // Variance
                    px -= rvL2.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 64; i++) {
                        for (int j = 0; j < 64; j++) {
                            s += pow(getVal(_Buffer, txL2, uint3(i, j, l), uint4(8, 8, 64, 64)) -
                                _Buffer.Load(uint3(rmL2.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 4096.0;
                    col.r = s;
                }
                else if (lcFloor == 5 && insideArea(txL2, px))
                {
                    // Normalization
                    px -= txL2.xy;
                    uint k = (px.x / 64) + (px.y / 64) * 8;
                    // z = (x - running_mean) / sqrt(running_var + epsilon)
                    // BN1 = gamma * z + beta
                    col.r = batchNorm(col.r, getVal(_Baked, nL2, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL2, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL2.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL2.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 6 && insideArea(txL3, px))
                {
                    // L3, kernel=4x4, stride=2, padding=1
                    px -= txL3.xy;
                    uint i = px.y % 32;
                    uint j = px.x % 32;
                    uint k = (px.x / 32) + (px.y / 32) * 16;

                    uint i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    float s = 0.0;
                    // kernel
                    for (int l = 0; l < 64; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL2, uint3(i0, j0, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i0, j1, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i0, j2, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i0, j3, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j0, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j1, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j2, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j3, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j0, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j1, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j2, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j3, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j0, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j1, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j2, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j3, l), uint4(8, 8, 64, 64), 63) * getWL3(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL3, k, bIndex); // bias
                    s = leakyRELU(s, 0.2); // activation

                    col.r = s;
                }
                else if (lcFloor == 7 && insideArea(rmL3, px))
                {
                    // Mean
                    px -= rmL3.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 32; i++) {
                        for (int j = 0; j < 32; j++) {
                            s += getVal(_Buffer, txL3, uint3(i, j, l), uint4(16, 16, 32, 32));
                        }
                    }
                    s /= 1024.0;
                    col.r = s;
                }
                else if (lcFloor == 8 && insideArea(rvL3, px))
                {
                    // Variance
                    px -= rvL3.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 32; i++) {
                        for (int j = 0; j < 32; j++) {
                            s += pow(getVal(_Buffer, txL3, uint3(i, j, l), uint4(16, 16, 32, 32)) -
                                _Buffer.Load(uint3(rmL3.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 1024.0;
                    col.r = s;
                }
                else if (lcFloor == 9 && insideArea(txL3, px))
                {
                    // Normalization
                    px -= txL3.xy;
                    uint k = (px.x / 32) + (px.y / 32) * 16;

                    col.r = batchNorm(col.r, getVal(_Baked, nL3, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL3, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL3.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL3.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 11 && insideArea(txL4, px))
                {
                    // L4, kernel=4x4, stride=2, padding=1
                    px -= txL4.xy;
                    uint i = px.y % 16;
                    uint j = px.x % 16;
                    uint k = (px.x / 16) + (px.y / 16) * 16;

                    uint i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    float s = 0.0;
                    // kernel
                    for (int l = 0; l < 128; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL3, uint3(i0, j0, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i0, j1, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i0, j2, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i0, j3, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j0, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j1, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j2, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j3, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j0, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j1, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j2, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j3, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j0, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j1, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j2, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j3, l), uint4(16, 16, 32, 32), 31) * getWL4(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL4, k, bIndex); // bias
                    s = leakyRELU(s, 0.2); // activation

                    col.r = s;
                }
                else if (lcFloor == 12 && insideArea(rmL4, px))
                {
                    // Mean
                    px -= rmL4.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 16; i++) {
                        for (int j = 0; j < 16; j++) {
                            s += getVal(_Buffer, txL4, uint3(i, j, l), uint4(16, 16, 16, 16));
                        }
                    }
                    s /= 256.0;
                    col.r = s;
                }
                else if (lcFloor == 13 && insideArea(rvL4, px))
                {
                    // Variance
                    px -= rvL4.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 16; i++) {
                        for (int j = 0; j < 16; j++) {
                            s += pow(getVal(_Buffer, txL4, uint3(i, j, l), uint4(16, 16, 16, 16)) -
                                _Buffer.Load(uint3(rmL4.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 256.0;
                    col.r = s;
                }
                else if (lcFloor == 14 && insideArea(txL4, px))
                {
                    // Normalization
                    px -= txL4.xy;
                    uint k = (px.x / 16) + (px.y / 16) * 16;

                    col.r = batchNorm(col.r, getVal(_Baked, nL4, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL4, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL4.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL4.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 15 &&insideArea(txL5, px))
                {
                    // L5, kernel=4x4, stride=2, padding=1
                    px -= txL5.xy;
                    uint i = px.y % 8;
                    uint j = px.x % 8;
                    uint k = (px.x / 8) + (px.y / 8) * 16;

                    uint i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    float s = 0.0;
                    // kernel
                    for (int l = 0; l < 256; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL4, uint3(i0, j0, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i0, j1, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i0, j2, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i0, j3, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j0, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j1, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j2, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j3, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j0, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j1, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j2, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j3, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j0, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j1, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j2, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j3, l), uint4(16, 16, 16, 16), 15) * getWL5(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL5, k, bIndex); // bias
                    s = leakyRELU(s, 0.2); // activation

                    col.r = s;
                }
                else if (lcFloor == 16 && insideArea(rmL5, px))
                {
                    // Mean
                    px -= rmL5.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 8; i++) {
                        for (int j = 0; j < 8; j++) {
                            s += getVal(_Buffer, txL5, uint3(i, j, l), uint4(16, 16, 8, 8));
                        }
                    }
                    s /= 64.0;
                    col.r = s;
                }
                else if (lcFloor == 17 && insideArea(rvL5, px))
                {
                    // Variance
                    px -= rvL5.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 8; i++) {
                        for (int j = 0; j < 8; j++) {
                            s += pow(getVal(_Buffer, txL5, uint3(i, j, l), uint4(16, 16, 8, 8)) -
                                _Buffer.Load(uint3(rmL5.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 64.0;
                    col.r = s;
                }
                else if (lcFloor == 18 && insideArea(txL5, px))
                {
                    // Normalization
                    px -= txL5.xy;
                    uint k = (px.x / 8) + (px.y / 8) * 16;

                    col.r = batchNorm(col.r, getVal(_Baked, nL5, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL5, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL5.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL5.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 19 && insideArea(txL6, px))
                {
                    // L6, kernel=4x4, stride=2, padding=1
                    px -= txL6.xy;
                    uint i = px.y % 4;
                    uint j = px.x % 4;
                    uint k = (px.x / 4) + (px.y / 4) * 16;

                    uint i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    float s = 0.0;
                    // kernel
                    for (int l = 0; l < 256; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL5, uint3(i0, j0, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i0, j1, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i0, j2, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i0, j3, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j0, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j1, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j2, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j3, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j0, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j1, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j2, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j3, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j0, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j1, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j2, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j3, l), uint4(16, 16, 8, 8), 7) * getWL6(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL6, k, bIndex); // bias
                    s = leakyRELU(s, 0.2); // activation

                    col.r = s;
                }
                else if (lcFloor == 20 && insideArea(rmL6, px))
                {
                    // Mean
                    px -= rmL6.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 4; i++) {
                        for (int j = 0; j < 4; j++) {
                            s += getVal(_Buffer, txL6, uint3(i, j, l), uint4(16, 16, 4, 4));
                        }
                    }
                    s /= 16.0;
                    col.r = s;
                }
                else if (lcFloor == 21 && insideArea(rvL6, px))
                {
                    // Variance
                    px -= rvL6.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 4; i++) {
                        for (int j = 0; j < 4; j++) {
                            s += pow(getVal(_Buffer, txL6, uint3(i, j, l), uint4(16, 16, 4, 4)) -
                                _Buffer.Load(uint3(rmL6.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 16.0;
                    col.r = s;
                }
                else if (lcFloor == 22 && insideArea(txL6, px))
                {
                    // Normalization
                    px -= txL6.xy;
                    uint k = (px.x / 4) + (px.y / 4) * 16;

                    col.r = batchNorm(col.r, getVal(_Baked, nL6, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL6, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL6.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL6.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 23 && insideArea(txL7, px))
                {
                    // L7, kernel=4x4, stride=2, padding=1
                    px -= txL7.xy;
                    uint i = px.y % 2;
                    uint j = px.x % 2;
                    uint k = (px.x / 2) + (px.y / 2) * 32;

                    uint i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    float s = 0.0;
                    for (int l = 0; l < 256; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL6, uint3(i0, j0, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i0, j1, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i0, j2, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i0, j3, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j0, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j1, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j2, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j3, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j0, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j1, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j2, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j3, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j0, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j1, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j2, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j3, l), uint4(16, 16, 4, 4), 3) * getWL7(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL7, k, bIndex);
                    s = leakyRELU(s, 0.2);

                    col.r = s;
                }
                else if (lcFloor == 24 && insideArea(rmL7, px))
                {
                    // Mean
                    px -= rmL7.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 2; i++) {
                        for (int j = 0; j < 2; j++) {
                            s += getVal(_Buffer, txL7, uint3(i, j, l), uint4(32, 32, 2, 2));
                        }
                    }
                    s /= 4.0;
                    col.r = s;
                }
                else if (lcFloor == 25 && insideArea(rvL7, px))
                {
                    // Variance
                    px -= rvL7.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 2; i++) {
                        for (int j = 0; j < 2; j++) {
                            s += pow(getVal(_Buffer, txL7, uint3(i, j, l), uint4(32, 32, 2, 2)) -
                                _Buffer.Load(uint3(rmL7.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 4.0;
                    col.r = s;
                }
                else if (lcFloor == 26 && insideArea(txL7, px))
                {
                    // Normalization
                    px -= txL7.xy;
                    uint k = (px.x / 2) + (px.y / 2) * 32;

                    col.r = batchNorm(col.r, getVal(_Baked, nL7, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL7, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL7.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL7.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 27 && insideArea(txL8, px))
                {
                    // L8, kernel=4x4, stride=1, padding=same(1,2)
                    px -= txL8.xy;
                    uint i = px.y % 4;
                    uint j = px.x % 4;
                    uint k = (px.x / 4) + (px.y / 4) * 32;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = uint(floor(i0 * 0.5));
                    i1 = uint(floor(i1 * 0.5));
                    i2 = uint(floor(i2 * 0.5));
                    i3 = uint(floor(i3 * 0.5));
                    j0 = uint(floor(j0 * 0.5));
                    j1 = uint(floor(j1 * 0.5));
                    j2 = uint(floor(j2 * 0.5));
                    j3 = uint(floor(j3 * 0.5));

                    float s = 0.0;
                    for (int l = 0; l < 512; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL7, uint3(i0, j0, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i0, j1, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i0, j2, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i0, j3, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i1, j0, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i1, j1, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i1, j2, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i1, j3, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i2, j0, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i2, j1, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i2, j2, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i2, j3, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i3, j0, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i3, j1, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i3, j2, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL7, uint3(i3, j3, l), uint4(32, 32, 2, 2), 1) * getWL8(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL8, k, bIndex);
                    s = RELU(s);

                    col.r = s;
                }
                else if (lcFloor == 28 && insideArea(rmL8, px))
                {
                    // Mean
                    px -= rmL8.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 4; i++) {
                        for (int j = 0; j < 4; j++) {
                            s += getVal(_Buffer, txL8, uint3(i, j, l), uint4(32, 32, 4, 4));
                        }
                    }
                    s /= 16.0;
                    col.r = s;
                }
                else if (lcFloor == 29 && insideArea(rvL8, px))
                {
                    // Variance
                    px -= rvL8.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 4; i++) {
                        for (int j = 0; j < 4; j++) {
                            s += pow(getVal(_Buffer, txL8, uint3(i, j, l), uint4(32, 32, 4, 4)) -
                                _Buffer.Load(uint3(rmL8.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 16.0;
                    col.r = s;
                }
                else if (lcFloor == 30 && insideArea(txL8, px))
                {
                    // Normalization
                    px -= txL8.xy;
                    uint k = (px.x / 4) + (px.y / 4) * 32;

                    col.r = batchNorm(col.r, getVal(_Baked, nL8, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL8, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL8.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL8.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 31 && insideArea(txL9, px))
                {
                    // L9, kernel=4x4, stride=1, padding=1,2
                    px -= txL9.xy;
                    uint i = px.y % 8;
                    uint j = px.x % 8;
                    uint k = (px.x / 8) + (px.y / 8) * 16;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    // uint -1 casts to 0, this is to make sure -1 turns into a big number
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = 0.0;
                    for (int l = 0; l < 512; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL8, uint3(i0, j0, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i0, j1, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i0, j2, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i0, j3, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i1, j0, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i1, j1, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i1, j2, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i1, j3, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i2, j0, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i2, j1, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i2, j2, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i2, j3, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i3, j0, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i3, j1, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i3, j2, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL8, uint3(i3, j3, l), uint4(32, 32, 4, 4), 3) * getWL9(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    col.r = s;

                    // No bias or activation, need to concatenate a previous layer
                }
                else if (lcFloor == 32 && insideArea(txL9, px))
                {
                    // L9 concatenation
                    px -= txL9.xy;
                    uint i = px.y % 8;
                    uint j = px.x % 8;
                    uint k = (px.x / 8) + (px.y / 8) * 16;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = col.r;
                    // Skip in a previous layer
                    for (int l = 512; l < 768; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL6, uint3(i0, j0, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i0, j1, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i0, j2, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i0, j3, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j0, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j1, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j2, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i1, j3, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j0, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j1, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j2, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i2, j3, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j0, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j1, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j2, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL6, uint3(i3, j3, l - 512), uint4(16, 16, 4, 4), 3) * getWL9(_Baked, uint4(3, 3, l, k), bIndex);
                    }
                    s += getBias(_Baked, bL9, k, bIndex);
                    s = RELU(s);

                    col.r = s;
                }
                else if (lcFloor == 33 && insideArea(rmL9, px))
                {
                    // Mean
                    px -= rmL9.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 8; i++) {
                        for (int j = 0; j < 8; j++) {
                            s += getVal(_Buffer, txL9, uint3(i, j, l), uint4(16, 16, 8, 8));
                        }
                    }
                    s /= 64.0;
                    col.r = s;
                }
                else if (lcFloor == 34 && insideArea(rvL9, px))
                {
                    // Variance
                    px -= rvL9.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 8; i++) {
                        for (int j = 0; j < 8; j++) {
                            s += pow(getVal(_Buffer, txL9, uint3(i, j, l), uint4(16, 16, 8, 8)) -
                                _Buffer.Load(uint3(rmL9.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 64.0;
                    col.r = s;
                }
                else if (lcFloor == 35 && insideArea(txL9, px))
                {
                    // Normalization
                    px -= txL9.xy;
                    uint k = (px.x / 8) + (px.y / 8) * 16;

                    col.r = batchNorm(col.r, getVal(_Baked, nL9, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL9, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL9.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL9.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 36 && insideArea(txL10, px))
                {
                    // L10, kernel=4x4, stride=1, padding=1,2
                    px -= txL10.xy;
                    uint i = px.y % 16;
                    uint j = px.x % 16;
                    uint k = (px.x / 16) + (px.y / 16) * 16;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = 0.0;
                    for (int l = 0; l < 256; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL9, uint3(i0, j0, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i0, j1, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i0, j2, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i0, j3, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i1, j0, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i1, j1, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i1, j2, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i1, j3, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i2, j0, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i2, j1, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i2, j2, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i2, j3, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i3, j0, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i3, j1, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i3, j2, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL9, uint3(i3, j3, l), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    col.r = s;

                    // No bias or activation, need to concatenate a previous layer
                }
                else if (lcFloor == 37 && insideArea(txL10, px))
                {
                    // L10 concat
                    px -= txL10.xy;
                    uint i = px.y % 16;
                    uint j = px.x % 16;
                    uint k = (px.x / 16) + (px.y / 16) * 16;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = col.r;
                    // Skip in a previous layer
                    for (int l = 256; l < 512; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL5, uint3(i0, j0, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i0, j1, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i0, j2, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i0, j3, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j0, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j1, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j2, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i1, j3, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j0, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j1, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j2, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i2, j3, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j0, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j1, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j2, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL5, uint3(i3, j3, l - 256), uint4(16, 16, 8, 8), 7) * getWL10(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL10, k, bIndex);
                    s = RELU(s);

                    col.r = s;
                }
                else if (lcFloor == 38 && insideArea(rmL10, px))
                {
                    // Mean
                    px -= rmL10.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 16; i++) {
                        for (int j = 0; j < 16; j++) {
                            s += getVal(_Buffer, txL10, uint3(i, j, l), uint4(16, 16, 16, 16));
                        }
                    }
                    s /= 256.0;
                    col.r = s;
                }
                else if (lcFloor == 39 && insideArea(rvL10, px))
                {
                    // Variance
                    px -= rvL10.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 16; i++) {
                        for (int j = 0; j < 16; j++) {
                            s += pow(getVal(_Buffer, txL10, uint3(i, j, l), uint4(16, 16, 16, 16)) -
                                _Buffer.Load(uint3(rmL10.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 256.0;
                    col.r = s;
                }
                else if (lcFloor == 40 && insideArea(txL10, px))
                {
                    // Normalization
                    px -= txL10.xy;
                    uint k = (px.x / 16) + (px.y / 16) * 16;

                    col.r = batchNorm(col.r, getVal(_Baked, nL10, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL10, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL10.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL10.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 41 && insideArea(txL11, px))
                {
                    // L11, kernel=4x4, stride=1, padding=1,2
                    px -= txL11.xy;
                    uint i = px.y % 32;
                    uint j = px.x % 32;
                    uint k = (px.x / 32) + (px.y / 32) * 16;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = 0.0;
                    for (int l = 0; l < 256; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL10, uint3(i0, j0, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i0, j1, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i0, j2, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i0, j3, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i1, j0, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i1, j1, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i1, j2, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i1, j3, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i2, j0, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i2, j1, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i2, j2, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i2, j3, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i3, j0, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i3, j1, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i3, j2, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL10, uint3(i3, j3, l), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    col.r = s;

                    // No bias or activation, need to concatenate a previous layer
                }
                else if (lcFloor == 42 && insideArea(txL11, px))
                {
                    // L11 concat
                    px -= txL11.xy;
                    uint i = px.y % 32;
                    uint j = px.x % 32;
                    uint k = (px.x / 32) + (px.y / 32) * 16;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = col.r;
                    // Skip in a previous layer
                    for (int l = 256; l < 512; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL4, uint3(i0, j0, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i0, j1, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i0, j2, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i0, j3, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j0, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j1, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j2, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i1, j3, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j0, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j1, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j2, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i2, j3, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j0, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j1, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j2, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL4, uint3(i3, j3, l - 256), uint4(16, 16, 16, 16), 15) * getWL11(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL11, k, bIndex);
                    s = RELU(s);

                    col.r = s;
                }
                else if (lcFloor == 43 && insideArea(rmL11, px))
                {
                    // Mean
                    px -= rmL11.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 32; i++) {
                        for (int j = 0; j < 32; j++) {
                            s += getVal(_Buffer, txL11, uint3(i, j, l), uint4(16, 16, 32, 32));
                        }
                    }
                    s /= 1024.0;
                    col.r = s;
                }
                else if (lcFloor == 44 && insideArea(rvL11, px))
                {
                    // Variance
                    px -= rvL11.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 32; i++) {
                        for (int j = 0; j < 32; j++) {
                            s += pow(getVal(_Buffer, txL11, uint3(i, j, l), uint4(16, 16, 32, 32)) -
                                _Buffer.Load(uint3(rmL11.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 1024.0;
                    col.r = s;
                }
                else if (lcFloor == 45 && insideArea(txL11, px))
                {
                    // Normalization
                    px -= txL11.xy;
                    uint k = (px.x / 32) + (px.y / 32) * 16;

                    col.r = batchNorm(col.r, getVal(_Baked, nL11, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL11, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL11.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL11.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 46 && insideArea(txL12, px))
                {
                    // L12, kernel=4x4, stride=1, padding=1,2
                    px -= txL12.xy;
                    uint i = px.y % 64;
                    uint j = px.x % 64;
                    uint k = (px.x / 64) + (px.y / 64) * 8;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = 0.0;
                    for (int l = 0; l < 128; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL11, uint3(i0, j0, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i0, j1, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i0, j2, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i0, j3, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i1, j0, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i1, j1, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i1, j2, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i1, j3, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i2, j0, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i2, j1, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i2, j2, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i2, j3, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i3, j0, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i3, j1, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i3, j2, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL11, uint3(i3, j3, l), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    col.r = s;

                    // No bias or activation, need to concatenate a previous layer
                }
                else if (lcFloor == 47 && insideArea(txL12, px))
                {
                    // L12 concat
                    px -= txL12.xy;
                    uint i = px.y % 64;
                    uint j = px.x % 64;
                    uint k = (px.x / 64) + (px.y / 64) * 8;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = col.r;
                    // Skip in a previous layer
                    for (int l = 128; l < 256; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL3, uint3(i0, j0, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i0, j1, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i0, j2, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i0, j3, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j0, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j1, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j2, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i1, j3, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j0, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j1, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j2, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i2, j3, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j0, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j1, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j2, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL3, uint3(i3, j3, l - 128), uint4(16, 16, 32, 32), 31) * getWL12(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL12, k, bIndex);
                    s = RELU(s);

                    col.r = s;
                }
                else if (lcFloor == 48 && insideArea(rmL12, px))
                {
                    // Mean
                    px -= rmL12.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 64; i++) {
                        for (int j = 0; j < 64; j++) {
                            s += getVal(_Buffer, txL12, uint3(i, j, l), uint4(8, 8, 64, 64));
                        }
                    }
                    s /= 4096.0;
                    col.r = s;
                }
                else if (lcFloor == 49 && insideArea(rvL12, px))
                {
                    // Variance
                    px -= rvL12.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 64; i++) {
                        for (int j = 0; j < 64; j++) {
                            s += pow(getVal(_Buffer, txL12, uint3(i, j, l), uint4(8, 8, 64, 64)) -
                                _Buffer.Load(uint3(rmL12.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 4096.0;
                    col.r = s;
                }
                else if (lcFloor == 50 && insideArea(txL12, px))
                {
                    // Normalization
                    px -= txL12.xy;
                    uint k = (px.x / 64) + (px.y / 64) * 8;

                    col.r = batchNorm(col.r, getVal(_Baked, nL12, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL12, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL12.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL12.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 51 && insideArea(txL13, px))
                {
                    // L13, kernel=4x4, stride=1, padding=1,2
                    px -= txL13.xy;
                    uint i = px.y % 128;
                    uint j = px.x % 128;
                    uint k = (px.x / 128) + (px.y / 128) * 8;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = 0.0;
                    for (int l = 0; l < 64; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL12, uint3(i0, j0, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i0, j1, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i0, j2, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i0, j3, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i1, j0, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i1, j1, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i1, j2, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i1, j3, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i2, j0, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i2, j1, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i2, j2, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i2, j3, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i3, j0, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i3, j1, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i3, j2, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL12, uint3(i3, j3, l), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    col.r = s;

                    // No bias or activation, need to concatenate a previous layer
                }
                else if (lcFloor == 52 && insideArea(txL13, px))
                {
                    // L13 concat
                    px -= txL13.xy;
                    uint i = px.y % 128;
                    uint j = px.x % 128;
                    uint k = (px.x / 128) + (px.y / 128) * 8;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = col.r;
                    // Skip in a previous layer
                    for (int l = 64; l < 128; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL2, uint3(i0, j0, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i0, j1, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i0, j2, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i0, j3, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j0, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j1, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j2, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i1, j3, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j0, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j1, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j2, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i2, j3, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j0, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j1, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j2, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL2, uint3(i3, j3, l - 64), uint4(8, 8, 64, 64), 63) * getWL13(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL13, k, bIndex);
                    s = RELU(s);

                    col.r = s;
                }
                else if (lcFloor == 53 && insideArea(rmL13, px))
                {
                    // Mean
                    px -= rmL13.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 128; i++) {
                        for (int j = 0; j < 128; j++) {
                            s += getVal(_Buffer, txL13, uint3(i, j, l), uint4(8, 8, 128, 128));
                        }
                    }
                    s /= 16384.0;
                    col.r = s;
                }
                else if (lcFloor == 54 && insideArea(rvL13, px))
                {
                    // Variance
                    px -= rvL13.xy;
                    uint l = px.x;
                    float s = 0.0;
                    for (int i = 0; i < 128; i++) {
                        for (int j = 0; j < 128; j++) {
                            s += pow(getVal(_Buffer, txL13, uint3(i, j, l), uint4(8, 8, 128, 128)) -
                                _Buffer.Load(uint3(rmL13.xy + uint2(l, 0), 0)), 2);
                        }
                    }
                    s /= 16384.0;
                    col.r = s;
                }
                else if (lcFloor == 55 && insideArea(txL13, px))
                {
                    // Normalization
                    px -= txL13.xy;
                    uint k = (px.x / 128) + (px.y / 128) * 8;

                    col.r = batchNorm(col.r, getVal(_Baked, nL13, uint3(k, 0, bIndex)),
                        getVal(_Baked, nL13, uint3(k, 1, bIndex)),
                        _Buffer.Load(uint3(rmL13.xy + uint2(k, 0), 0)),
                        _Buffer.Load(uint3(rvL13.xy + uint2(k, 0), 0)));
                }
                else if (lcFloor == 56 && insideArea(txL14, px))
                {
                    // L14, kernel=4x4, stride=1, padding=1,2
                    px -= txL14.xy;
                    uint i = px.y % 256;
                    uint j = px.x % 256;
                    uint k = px.x / 256;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = 0.0;
                    for (int l = 0; l < 64; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL13, uint3(i0, j0, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i0, j1, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i0, j2, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i0, j3, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i1, j0, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i1, j1, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i1, j2, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i1, j3, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i2, j0, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i2, j1, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i2, j2, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i2, j3, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i3, j0, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i3, j1, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i3, j2, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL13, uint3(i3, j3, l), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    col.r = s;

                    // No bias or activation, need to concatenate a previous layer
                }
                else if (lcFloor == 57 && insideArea(txL14, px))
                {
                    // L14 concat
                    px -= txL14.xy;
                    uint i = px.y % 256;
                    uint j = px.x % 256;
                    uint k = px.x / 256;

                    uint i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
                    uint j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

                    // Nearest neighbor upscaling
                    i0 = (floor(i0 * 0.5)) < 0.0 ? MAX_UINT : (floor(i0 * 0.5));
                    i1 = (floor(i1 * 0.5));
                    i2 = (floor(i2 * 0.5));
                    i3 = (floor(i3 * 0.5));
                    j0 = (floor(j0 * 0.5)) < 0.0 ? MAX_UINT : (floor(j0 * 0.5));
                    j1 = (floor(j1 * 0.5));
                    j2 = (floor(j2 * 0.5));
                    j3 = (floor(j3 * 0.5));

                    float s = col.r;
                    // Skip in a previous layer
                    for (int l = 64; l < 128; l++) {
                        s +=
                            padOneGetVal(_Buffer, txL1, uint3(i0, j0, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i0, j1, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i0, j2, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i0, j3, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(0, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j0, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j1, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j2, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i1, j3, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(1, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j0, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j1, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j2, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i2, j3, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(2, 3, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j0, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 0, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j1, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 1, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j2, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 2, l, k), bIndex) +
                            padOneGetVal(_Buffer, txL1, uint3(i3, j3, l - 64), uint4(8, 8, 128, 128), 127) * getWL14(_Baked, uint4(3, 3, l, k), bIndex);
                    }

                    s += getBias(_Baked, bL14, k, bIndex);
                    s = tanh(s);

                    col.r = s;

                    // uint i = px.y % 128;
                    // uint j = px.x % 128;
                    // if (i == 25 && j == 26 && k == 0)
                    //      buffer[0] = col.rrrr;
                }

                lcFloor = min((lcFloor + 1), 58);
                StoreValue(txLC, lcFloor, col, px);
                StoreValue(txTimer, timer, col, px);
                return col;
            }
            ENDCG
        }
    }
}
