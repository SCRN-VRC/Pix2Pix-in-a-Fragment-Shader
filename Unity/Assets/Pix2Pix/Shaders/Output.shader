Shader "Pix2Pix/Output"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Pix2PixLayout.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            Texture2D<float4> _MainTex;
            float4 _MainTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 nuv = i.uv;
                nuv *= txL14.w;
                nuv.y += _MainTex_TexelSize.w / 2.0;

                float4 col;
                col.r = (_MainTex.Load(uint3(nuv, 0)).r + 1.0) / 2.0;
                nuv.x += 256;
                col.g = (_MainTex.Load(uint3(nuv, 0)).r + 1.0) / 2.0;
                nuv.x += 256;
                col.b = (_MainTex.Load(uint3(nuv, 0)).r + 1.0) / 2.0;
                col.a = 1.0;

                col.rgb = pow(col.rgb, 2);
                return col;
            }
            ENDCG
        }
    }
}
