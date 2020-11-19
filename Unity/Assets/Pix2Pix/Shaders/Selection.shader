Shader "Pix2Pix/Selection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SelControl ("Selection Controller", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        
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
            Texture2D<float4> _SelControl;
            float4 _MainTex_ST;

            // https://www.shadertoy.com/view/4llXD7
            float sdRoundBox( in float2 p, in float2 b, in float4 r ) 
            {
                r.xy = (p.x>0.0)?r.xy : r.zw;
                r.x  = (p.y>0.0)?r.x  : r.y;

                float2 q = abs(p)-b+r.x;
                return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                
                // Network Select
                float4 edgeExampleTrans = LoadValue(_SelControl, uint2(0, 1));
                float2 pos = (i.uv - 0.5) - float2(0.0, 0.113) * (3.0 - edgeExampleTrans.x);
                float d = sdRoundBox(pos, float2(0.3333, 0.06), 0.03.xxxx);
                col = lerp(col, float4(0.5, 1.0, 0.0, 1.0), 1.0 - (abs(d) < 0.005 ? 0.0 : 1.0));

                // Examples Select
                pos = (i.uv - 0.5) + float2(0.213, 0.198) -
                    float2(0.14 * edgeExampleTrans.y, -0.075 * edgeExampleTrans.z);
                d = sdRoundBox(pos, float2(0.045, 0.045), 0.03.xxxx);
                col = lerp(col, float4(0.0, 0.5, 1.0, 1.0), 1.0 - (abs(d) < 0.003 ? 0.0 : 1.0));

                // Clear Select
                float4 clearEdgeExampleChange = LoadValue(_SelControl, uint2(1, 0));
                pos = (i.uv - 0.5) + float2(0.0, 0.39);
                d = sdRoundBox(pos, float2(0.28, 0.05) * clearEdgeExampleChange.x, 0.03.xxxx);
                col = lerp(col, float4(1.0, 0.1, 0.0, 1.0), 1.0 - (sign(d) < 0.003 ? 0.0 : 1.0));

                col.rgb *= col.a;
                return col;
            }
            ENDCG
        }
    }
}
