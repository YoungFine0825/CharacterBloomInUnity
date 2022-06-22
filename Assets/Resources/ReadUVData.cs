using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class ReadUVData : MonoBehaviour
{
    public bool forceRefresh = false;

    public string uvDataPath = string.Empty;

    public int offset = 0;

    private void Awake()
    {
        string uvFile = Application.dataPath + '/' + uvDataPath;

        StreamReader sr = new StreamReader(uvFile);

        if (sr == null)
        {
            return;
        }

        //
        MeshFilter meshF = GetComponent<MeshFilter>();
        Mesh mesh = meshF.sharedMesh;
        int vertCnt = mesh.vertexCount;
        //
        Debug.Log(mesh.triangles.Length);
        //
        if (mesh.uv.Length >= vertCnt && !forceRefresh)
        {
            return;
        }
        Vector2[] uv = new Vector2[vertCnt];
        //
        int vecCom = 0;
        string line = string.Empty;
        while ((line = sr.ReadLine()) != null)
        {
            string[] numbers = line.Split('\t');
            int vertIdx = System.Convert.ToInt32(numbers[0]);
            if (vertIdx - offset < 0) { continue; }
            //
            vertIdx = vertIdx - offset;
            //
            float coord = System.Convert.ToSingle(numbers[1]);
            if (vertIdx >= vertCnt) { break; }
            //
            if (vecCom == 1)
            {
                uv[vertIdx][vecCom] = 1 - coord;
            }
            else
            {
                uv[vertIdx][vecCom] = coord;
            }
            //
            vecCom = ++vecCom % 2;
            //
        }
        //
        mesh.uv = uv;
        //
        //int[] indexBuffer = mesh.triangles;
        //int trianglesNumber = indexBuffer.Length / 3;
        //for (int triIdx = 0; triIdx < trianglesNumber; triIdx++)
        //{
        //    int vertex1 = indexBuffer[triIdx * 3 + 0];
        //    int vertex2 = indexBuffer[triIdx * 3 + 1];
        //    int vertex3 = indexBuffer[triIdx * 3 + 2];
        //    indexBuffer[triIdx * 3 + 0] = vertex2;
        //    indexBuffer[triIdx * 3 + 1] = vertex1;
        //    indexBuffer[triIdx * 3 + 2] = vertex3;
        //}
        //mesh.triangles = indexBuffer;
        //
        sr.Close();
    }
}
