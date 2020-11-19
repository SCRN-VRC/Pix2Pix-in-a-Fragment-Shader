#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.UI;

[ExecuteInEditMode]
public class Pix2PixWeights : EditorWindow
{
    public TextAsset source0;
    public TextAsset source1;
    public TextAsset source2;
    public TextAsset source3;

    string SavePath = "Assets/Pix2Pix/Weights/WeightsTex.asset";

    [MenuItem("Tools/SCRN/Bake Pix2Pix")]
    static void Init()
    {
        var window = GetWindowWithRect<Pix2PixWeights>(new Rect(0, 0, 400, 250));
        window.Show();
    }
    
    void OnGUI()
    {
        GUILayout.Label("Bake Pix2Pix", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        EditorGUILayout.BeginHorizontal();
        source0 = (TextAsset) EditorGUILayout.ObjectField("Pix2Pix Weights0 (.bytes):", source0, typeof(TextAsset), false);
        EditorGUILayout.EndHorizontal();
        source1 = (TextAsset) EditorGUILayout.ObjectField("Pix2Pix Weights1 (.bytes):", source1, typeof(TextAsset), false);
        source2 = (TextAsset) EditorGUILayout.ObjectField("Pix2Pix Weights2 (.bytes):", source2, typeof(TextAsset), false);
        source3 = (TextAsset) EditorGUILayout.ObjectField("Pix2Pix Weights3 (.bytes):", source3, typeof(TextAsset), false);
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("Bake!")) {
            OnGenerateTexture();
        }
    }

    void OnGenerateTexture()
    {
        if (source0 != null && source1 != null && source2 != null && source3 != null)
        {
            const int width = 4096;
            const int height = 4096;
            Texture2D tex = new Texture2D(width, height, TextureFormat.RGBAHalf, false);
            tex.wrapMode = TextureWrapMode.Clamp;
            tex.filterMode = FilterMode.Point;
            tex.anisoLevel = 1;
            
            ExtractFromBin(tex, source0, source1, source2, source3);
            AssetDatabase.CreateAsset(tex, SavePath);
            AssetDatabase.SaveAssets();

            ShowNotification(new GUIContent("Done"));
        }
    }

    void getBlock(Texture2D tex, BinaryReader br0, BinaryReader br1, BinaryReader br2,
        BinaryReader br3, int totalFloats, int destX, int destY, int width)
    {
        for (int i = 0; i < totalFloats; i++)
        {
            int x = i % width;
            int y = i / width;
            tex.SetPixel(x + destX, y + destY,
                new Color(br0.ReadSingle(), br1.ReadSingle(), br2.ReadSingle(), br3.ReadSingle()));
        }
    }

    void ExtractFromBin(Texture2D tex, TextAsset srcIn0, TextAsset srcIn1, TextAsset srcIn2,
        TextAsset srcIn3)
    {
        Stream s0 = new MemoryStream(srcIn0.bytes);
        Stream s1 = new MemoryStream(srcIn1.bytes);
        Stream s2 = new MemoryStream(srcIn2.bytes);
        Stream s3 = new MemoryStream(srcIn3.bytes);
        BinaryReader br0 = new BinaryReader(s0);
        BinaryReader br1 = new BinaryReader(s1);
        BinaryReader br2 = new BinaryReader(s2);
        BinaryReader br3 = new BinaryReader(s3);

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 3 * 64, 3328, 3328, 768);     //wL1
        getBlock(tex, br0, br1, br2, br3, 64, 2560, 3644, 64);                  //bL1

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 64 * 64, 3072, 3328, 256);    //wL2
        getBlock(tex, br0, br1, br2, br3, 64, 2560, 3643, 64);                  //bL2
        getBlock(tex, br0, br1, br2, br3, 64 * 4, 2560, 3639, 64);              //nL2

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 64 * 128, 2048, 3840, 512);   //wL3
        getBlock(tex, br0, br1, br2, br3, 128, 2560, 3628, 128);                //bL3
        getBlock(tex, br0, br1, br2, br3, 128 * 4, 2560, 3624, 128);            //nL3

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 128 * 256, 1024, 3584, 1024); //wL4
        getBlock(tex, br0, br1, br2, br3, 256, 2560, 3618, 256);                //bL4
        getBlock(tex, br0, br1, br2, br3, 256 * 4, 2560, 3614, 256);            //nL4

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 256 * 256, 3072, 0, 1024);    //wL5
        getBlock(tex, br0, br1, br2, br3, 256, 2560, 3613, 256);                //bL5
        getBlock(tex, br0, br1, br2, br3, 256 * 4, 2560, 3609, 256);            //nL5

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 256 * 256, 0, 3072, 1024);    //wL6
        getBlock(tex, br0, br1, br2, br3, 256, 2560, 3608, 256);                //bL6
        getBlock(tex, br0, br1, br2, br3, 256 * 4, 2560, 3604, 256);            //nL6

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 256 * 512, 2048, 2048, 2048); //wL7
        getBlock(tex, br0, br1, br2, br3, 512, 2560, 3593, 512);                //bL7
        getBlock(tex, br0, br1, br2, br3, 512 * 4, 2560, 3589, 512);            //nL7

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 512 * 512, 0, 1024, 2048);    //wL8
        getBlock(tex, br0, br1, br2, br3, 512, 2560, 3588, 512);                //bL8
        getBlock(tex, br0, br1, br2, br3, 512 * 4, 2560, 3584, 512);            //nL8

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 768 * 256, 0, 0, 3072);       //wL9
        getBlock(tex, br0, br1, br2, br3, 256, 2560, 3603, 256);                //bL9
        getBlock(tex, br0, br1, br2, br3, 256 * 4, 2560, 3599, 256);            //nL9

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 512 * 256, 2048, 1024, 2048); //wL10
        getBlock(tex, br0, br1, br2, br3, 256, 2560, 3598, 256);                //bL10
        getBlock(tex, br0, br1, br2, br3, 256 * 4, 2560, 3594, 256);            //nL10

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 512 * 128, 1024, 3072, 2048); //wL11
        getBlock(tex, br0, br1, br2, br3, 128, 2560, 3623, 128);                //bL11
        getBlock(tex, br0, br1, br2, br3, 128 * 4, 2560, 3619, 128);            //nL11

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 256 * 64, 3072, 3072, 1024);  //wL12
        getBlock(tex, br0, br1, br2, br3, 64, 2560, 3638, 64);                  //bL12
        getBlock(tex, br0, br1, br2, br3, 64 * 4, 2560, 3634, 64);              //nL12

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 128 * 64, 2048, 3584, 512);   //wL13
        getBlock(tex, br0, br1, br2, br3, 64, 2560, 3633, 64);                  //bL13
        getBlock(tex, br0, br1, br2, br3, 64 * 4, 2560, 3629, 64);              //nL13

        getBlock(tex, br0, br1, br2, br3, 4 * 4 * 128 * 4, 3328, 3332, 512);    //wL13
        getBlock(tex, br0, br1, br2, br3, 3, 2560, 3645, 3);                    //bL13
    }
}

#endif