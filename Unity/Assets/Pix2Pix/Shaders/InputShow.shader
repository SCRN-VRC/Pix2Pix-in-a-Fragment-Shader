Shader "Pix2Pix/InputShow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ExampleTex ("Examples", 2D) = "white" {}
        _SelControl ("Selection Controller", 2D) = "black" {}
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

            sampler2D _MainTex;
            sampler2D _ExampleTex;
            Texture2D<float4> _SelControl;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float4 curXYEdgeExample = LoadValue(_SelControl, uint2(0, 0));
                float4 clearEdgeExampleChange = LoadValue(_SelControl, uint2(1, 0));

                //col.rgb = (col.r + col.g + col.b) * 0.3333 < 0.6 ? 0.0 : 1.0;
                col.rgba = (_Time.y < 1.0 || clearEdgeExampleChange.x > 0.0) ? 1.0 : col.rgba;

                if (clearEdgeExampleChange.z > 0.0 || _Time.y < 1.0)
                {
                    col = tex2D(_ExampleTex, i.uv * float2(0.25, 0.5) +
                        float2(0.25 * (floor(fmod(curXYEdgeExample.w, 4.0))),
                            0.5 * floor(curXYEdgeExample.w * 0.25)));
                }

                return col;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
