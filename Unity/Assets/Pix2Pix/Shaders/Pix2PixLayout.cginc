#ifndef _PIX2PIXLAYOUT
#define _PIX2PIXLAYOUT

// Layer positions
#define txL1                     uint4(0, 0, 1024, 1024)           // 128 x 128 x 64
#define txL2                     uint4(0, 1280, 512, 512)          // 64 x 64 x 64
#define txL3                     uint4(0, 1792, 512, 256)          // 32 x 32 x 128
#define txL4                     uint4(768, 1024, 256, 256)        // 16 x 16 x 256
#define txL5                     uint4(1408, 1024, 128, 128)       // 8 x 8 x 256
#define txL6                     uint4(1408, 1152, 64, 64)         // 4 x 4 x 256
#define txL7                     uint4(1472, 1152, 64, 32)         // 2 x 2 x 512
#define txL8                     uint4(1280, 1152, 128, 64)        // 4 x 4 x 512
#define txL9                     uint4(1280, 1024, 128, 128)       // 8 x 8 x 256
#define txL10                    uint4(1024, 1024, 256, 256)       // 16 x 16 x 256
#define txL11                    uint4(512, 1792, 512, 256)        // 32 x 32 x 128
#define txL12                    uint4(512, 1280, 512, 512)        // 64 x 64 x 64
#define txL13                    uint4(1024, 0, 1024, 1024)        // 128 x 128 x 64
#define txL14                    uint4(0, 1024, 768, 256)          // 256 x 256 x 3

// Running mean + variance
#define rmL2                     uint4(1536, 1044, 64, 1)       // 64
#define rmL3                     uint4(1536, 1039, 128, 1)      // 128
#define rmL4                     uint4(1536, 1030, 256, 1)      // 256
#define rmL5                     uint4(1536, 1029, 256, 1)      // 256
#define rmL6                     uint4(1536, 1028, 256, 1)      // 256
#define rmL7                     uint4(1536, 1025, 512, 1)      // 512
#define rmL8                     uint4(1536, 1024, 512, 1)      // 512
#define rmL9                     uint4(1536, 1032, 256, 1)      // 256
#define rmL10                    uint4(1536, 1031, 256, 1)      // 256
#define rmL11                    uint4(1536, 1038, 128, 1)      // 128
#define rmL12                    uint4(1536, 1043, 64, 1)       // 64
#define rmL13                    uint4(1536, 1042, 64, 1)       // 64

#define rvL2                     uint4(1536, 1047, 64, 1)       // 64
#define rvL3                     uint4(1536, 1041, 128, 1)      // 128
#define rvL4                     uint4(1536, 1037, 256, 1)      // 256
#define rvL5                     uint4(1536, 1036, 256, 1)      // 256
#define rvL6                     uint4(1536, 1035, 256, 1)      // 256
#define rvL7                     uint4(1536, 1027, 512, 1)      // 512
#define rvL8                     uint4(1536, 1026, 512, 1)      // 512
#define rvL9                     uint4(1536, 1034, 256, 1)      // 256
#define rvL10                    uint4(1536, 1033, 256, 1)      // 256
#define rvL11                    uint4(1536, 1040, 128, 1)      // 128
#define rvL12                    uint4(1536, 1046, 64, 1)       // 64
#define rvL13                    uint4(1536, 1045, 64, 1)       // 64

// Weight positions
#define wL1                      uint4(3328, 3328, 768, 4)         // 4 x 4 x 3 x 64
#define wL2                      uint4(3072, 3328, 256, 256)       // 4 x 4 x 64 x 64
#define wL3                      uint4(2048, 3840, 512, 256)       // 4 x 4 x 64 x 128
#define wL4                      uint4(1024, 3584, 1024, 512)      // 4 x 4 x 128 x 256
#define wL5                      uint4(3072, 0, 1024, 1024)        // 4 x 4 x 256 x 256
#define wL6                      uint4(0, 3072, 1024, 1024)        // 4 x 4 x 256 x 256
#define wL7                      uint4(2048, 2048, 2048, 1024)     // 4 x 4 x 256 x 512
#define wL8                      uint4(0, 1024, 2048, 2048)        // 4 x 4 x 512 x 512
#define wL9                      uint4(0, 0, 3072, 1024)           // 4 x 4 x 768 x 256
#define wL10                     uint4(2048, 1024, 2048, 1024)     // 4 x 4 x 512 x 256
#define wL11                     uint4(1024, 3072, 2048, 512)      // 4 x 4 x 512 x 128
#define wL12                     uint4(3072, 3072, 1024, 256)      // 4 x 4 x 256 x 64
#define wL13                     uint4(2048, 3584, 512, 256)       // 4 x 4 x 128 x 64
#define wL14                     uint4(3328, 3332, 512, 16)        // 4 x 4 x 128 x 4

// Bias + normalization positions
#define bL1                      uint4(2560, 3644, 64, 1)      // 64
#define bL2                      uint4(2560, 3643, 64, 1)      // 64
#define nL2                      uint4(2560, 3639, 64, 4)      // 64 x 4
#define bL3                      uint4(2560, 3628, 128, 1)     // 128
#define nL3                      uint4(2560, 3624, 128, 4)     // 128 x 4
#define bL4                      uint4(2560, 3618, 256, 1)     // 256
#define nL4                      uint4(2560, 3614, 256, 4)     // 256 x 4
#define bL5                      uint4(2560, 3613, 256, 1)     // 256
#define nL5                      uint4(2560, 3609, 256, 4)     // 256 x 4
#define bL6                      uint4(2560, 3608, 256, 1)     // 256
#define nL6                      uint4(2560, 3604, 256, 4)     // 256 x 4
#define bL7                      uint4(2560, 3593, 512, 1)     // 512
#define nL7                      uint4(2560, 3589, 512, 4)     // 512 x 4
#define bL8                      uint4(2560, 3588, 512, 1)     // 512
#define nL8                      uint4(2560, 3584, 512, 4)     // 512 x 4
#define bL9                      uint4(2560, 3603, 256, 1)     // 256
#define nL9                      uint4(2560, 3599, 256, 4)     // 256 x 4
#define bL10                     uint4(2560, 3598, 256, 1)     // 256
#define nL10                     uint4(2560, 3594, 256, 4)     // 256 x 4
#define bL11                     uint4(2560, 3623, 128, 1)     // 128
#define nL11                     uint4(2560, 3619, 128, 4)     // 128 x 4
#define bL12                     uint4(2560, 3638, 64, 1)      // 64
#define nL12                     uint4(2560, 3634, 64, 4)      // 64 x 4
#define bL13                     uint4(2560, 3633, 64, 1)      // 64
#define nL13                     uint4(2560, 3629, 64, 4)      // 64 x 4
#define bL14                     uint4(2560, 3645, 3, 1)       // 3


// Global variables
#define MAX_UINT                 10000000
#define epsilon                  0.001

#define txTimer                  uint2(1472, 1184)
#define txLC                     uint2(1473, 1184)
#define txUpdate                 uint2(1474, 1184)

float test(uint3 pos, uint maxNum)
{
    float r;
    if (pos.z == 0)
        r = (pos.x / 255.0) * (pos.y /  255.0) * 2.0 - 1.0;
    else if (pos.z == 1)
        r = ((255.0 - pos.x) / 255.0) * (pos.y /  255.0) * 2.0 - 1.0;
    else
        r = (pos.x / 255.0) * ((255.0 - pos.y) /  255.0) * 2.0 - 1.0;
    r = pos.x > maxNum ? 0.0 : r;
    r = pos.y > maxNum ? 0.0 : r;
    return r;
}

float leakyRELU(float x, float alpha)
{
    return x < 0.0 ? (alpha * x) : x;
}

float RELU(float x)
{
    return max(x, 0.0);
}

float batchNorm(float x, float gamma, float beta, float mean, float var)
{
    return ((x - mean) / sqrt(var + epsilon)) * gamma + beta;
}

float getWL1(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + pos.z * 64 + pos.y * 192;
    p.y = pos.x;
    return tex.Load(uint3(wL1.xy + p, 0))[index];
}

float getWL2(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 4) * 64;
    p.y = (pos.z / 4) + pos.y * 16 + pos.x * 64;
    return tex.Load(uint3(wL2.xy + p, 0))[index];
}

float getWL3(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 4) * 128;
    p.y = (pos.z / 4) + pos.y * 16 + pos.x * 64;
    return tex.Load(uint3(wL3.xy + p, 0))[index];
}

float getWL4(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 4) * 256;
    p.y = (pos.z / 4) + pos.y * 32 + pos.x * 128;
    return tex.Load(uint3(wL4.xy + p, 0))[index];
}

float getWL5(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 4) * 256;
    p.y = (pos.z / 4) + pos.y * 64 + pos.x * 256;
    return tex.Load(uint3(wL5.xy + p, 0))[index];
}

float getWL6(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 4) * 256;
    p.y = (pos.z / 4) + pos.y * 64 + pos.x * 256;
    return tex.Load(uint3(wL6.xy + p, 0))[index];
}

float getWL7(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 4) * 512;
    p.y = (pos.z / 4) + pos.y * 64 + pos.x * 256;
    return tex.Load(uint3(wL7.xy + p, 0))[index];
}

float getWL8(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 4) * 512;
    p.y = (pos.z / 4) + pos.y * 128 + pos.x * 512;
    return tex.Load(uint3(wL8.xy + p, 0))[index];
}

float getWL9(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 12) * 256;
    p.y = (pos.z / 12) + pos.y * 64 + pos.x * 256;
    return tex.Load(uint3(wL9.xy + p, 0))[index];
}

float getWL10(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 8) * 256;
    p.y = (pos.z / 8) + pos.y * 64 + pos.x * 256;
    return tex.Load(uint3(wL10.xy + p, 0))[index];
}

float getWL11(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 16) * 128;
    p.y = (pos.z / 16) + pos.y * 32 + pos.x * 128;
    return tex.Load(uint3(wL11.xy + p, 0))[index];
}

float getWL12(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 16) * 64;
    p.y = (pos.z / 16) + pos.y * 16 + pos.x * 64;
    return tex.Load(uint3(wL12.xy + p, 0))[index];
}

float getWL13(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + (pos.z % 8) * 64;
    p.y = (pos.z / 8) + pos.y * 16 + pos.x * 64;
    return tex.Load(uint3(wL13.xy + p, 0))[index];
}

float getWL14(Texture2D<float4> tex, uint4 pos, uint index)
{
    uint2 p = 0;
    p.x = pos.w + pos.z * 4;
    p.y = pos.y + pos.x * 4;
    return tex.Load(uint3(wL14.xy + p, 0))[index];
}

float getBias(Texture2D<float4> tex, uint4 offset, uint pos, uint index)
{
    uint2 p = 0;
    p.x = pos;
    p.y = 0;
    return tex.Load(uint3(offset.xy + p, 0))[index];
}

float getVal(Texture2D<float4> tex, uint4 offset, uint3 pos)
{
    return tex.Load(uint3(offset.xy + pos.xy, 0))[pos.z];
}

float getVal(Texture2D<float> tex, uint4 offset, uint2 pos)
{
    return tex.Load(uint3(offset.xy + pos, 0));
}

float getVal(Texture2D<float> tex, uint4 offset, uint3 pos, uint4 mult)
{
    uint2 p = 0;
    p.x = pos.y + (pos.z % mult.x) * mult.z;
    p.y = pos.x + (pos.z / mult.y) * mult.w;
    return tex.Load(uint3(offset.xy + p, 0));
}

float padOneGetVal(Texture2D<float> tex, uint4 offset, uint3 pos, uint4 mult, uint maxNum)
{
    float r = getVal(tex, offset, pos, mult);
    r = pos.x > maxNum ? 0.0 : r;
    r = pos.y > maxNum ? 0.0 : r;
    return r;
}

float padOneGetImg(Texture2D<float4> tex, uint3 pos, uint maxNum)
{
    float val = tex.Load(uint3(pos.xy, 0))[pos.z] * 2.0 - 1.0;
    val = pos.x > maxNum ? 0.0 : val;
    val = pos.y > maxNum ? 0.0 : val;
    return val;
}

inline bool insideArea(in uint4 area, uint2 px)
{
    [flatten]
    if (px.x >= area.x && px.x < (area.x + area.z) &&
        px.y >= area.y && px.y < (area.y + area.w))
    {
        return true;
    }
    return false;
}

inline float LoadValue(in Texture2D<float> tex, in uint2 re)
{
    return tex.Load(int3(re, 0));
}

inline float4 LoadValue(in Texture2D<float4> tex, in uint2 re)
{
    return tex.Load(int3(re, 0));
}

inline void StoreValue(in uint2 txPos, in float value, inout float col,
    in uint2 fragPos)
{
    col = all(fragPos == txPos) ? value : col;
}

inline void StoreValue(in uint2 txPos, in float4 value, inout float4 col,
    in uint2 fragPos)
{
    col = all(fragPos == txPos) ? value : col;
}

#endif