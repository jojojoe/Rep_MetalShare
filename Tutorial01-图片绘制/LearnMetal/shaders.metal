//
//  shaders.metal
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//

#include <metal_stdlib>
#import "LYShaderTypes.h"


/*
 资源有了，我们要告诉 GPU 怎么去使用这些数据，这里就需要 Shader 了，
 这部分代码是在 GPU 中执行的，所以要用特殊的语言去编写，即 Metal Shading Language，
 它是 C++ 14的超集，封装了一些 Metal 的数据格式和常用方法。
 你可以添加多个 Metal 文件，最后都会编译到二进制文件default.metallib 中。
 通过 Xcode 的 File - New - File 菜单，新建一个 Metal 文件。
 
 
 
 
 
 */



using namespace metal;

//typedef struct
//{
//    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
//
//    float2 textureCoordinate; // 纹理坐标，会做插值处理
//
//} RasterizerData;

typedef struct
{
    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
    float3 textureColor; // mark
    float2 textureCoordinate; // 纹理坐标，会做插值处理
    
    
    
} RasterizerData;


/*
 
 RasterizerData 返回给片元着色器的结构体
 
 vertexShader 为方法名，vertex 代表是一个顶点函数 VertexOut 代表返回值，该方法有两个入参。
 
 vertexID 代表着进入的顶点的 id 即顺序。
 vertexArray 后面的 buff(0) buffer表明是缓存数据，0是索引

 
 这里可以对顶点进行处理，如转向，3D 场景下的光影的计算等等，然后返回处理之后的顶点信息，这里直接返回，并没有做额外的处理。
 
 */




vertex RasterizerData // 返回给片元着色器的结构体
vertexShader(uint vertexID [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
             constant LYVertex *vertexArray [[ buffer(0) ]]) { // buffer表明是缓存数据，0是索引
    RasterizerData out;
    out.clipSpacePosition = vertexArray[vertexID].position;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
//    out.textureColor = vertexArray[vertexID].textureColor; // mark
    return out;
}


/*
 
 myFragmentShader 同上，fragment 代表是一个处理片段的方法，方法有两个入参
 
 RasterizerData input [[stage_in]] 代表着从顶点返回的顶点信息
 
 texture2d colorTexture [[ texture(0) ]] 读入的图片资源
 
 
 sampler textureSampler 采样器
 
 
 */


/*
 顶点着色器返回了 VertexOut 结构体，通过 [[stage_in]] 入参，
 它的值会是根据你的渲染的位置来插值。
 所以这个方法的主要内容就是根据，之前返回的顶点信息，去图像中采样得到相应位置的样色，并返回颜色。
 
 */

//fragment float4
//samplingShader(RasterizerData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
//               texture2d<half> colorTexture [[ texture(0) ]]) // texture表明是纹理数据，0是索引
//{
//    constexpr sampler textureSampler (mag_filter::linear,
//                                      min_filter::linear); // sampler是采样器
//
//    half4 colorSample = colorTexture.sample(textureSampler, input.textureCoordinate); // 得到纹理对应位置的颜色
//
//
//    float4 colorSample_color = float4(input.textureColor, 1.0f); // mark
//
//    float4 color = float4(colorSample) * colorSample_color;
//
//    return float4(color);
//
//
//}

fragment float4
samplingShader(RasterizerData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
               texture2d<half> colorTexture [[ texture(0) ]]) // texture表明是纹理数据，0是索引
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器

    half4 colorSample = colorTexture.sample(textureSampler, input.textureCoordinate); // 得到纹理对应位置的颜色

    return float4(colorSample);
}
