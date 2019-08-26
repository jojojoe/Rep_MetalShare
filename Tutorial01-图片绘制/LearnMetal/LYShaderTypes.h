//
//  LYShaderTypes.h
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//

#ifndef LYShaderTypes_h
#define LYShaderTypes_h

/*
 里面的 float4 和 float2 代表着 4 个和 2 个浮点数的向量。
 */
//typedef struct
//{
//    vector_float4 position;
//    vector_float3 textureColor; // mark
//    vector_float2 textureCoordinate;
//    
//} LYVertex;

typedef struct
{
    vector_float4 position;
//    vector_float3 textureColor; // mark
    vector_float2 textureCoordinate;
    
} LYVertex;

#endif /* LYShaderTypes_h */
