#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct
{
    vector_float2 position;
    vector_float4 color;
} Vertex;

typedef struct
{
    float4 clipSpacePosition [[position]];
    float4 color;

} RasterizerData;

// 顶点着色器
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],

             constant Vertex *vertices [[buffer(0)]])
{
    RasterizerData out;
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    out.clipSpacePosition.xy = pixelSpacePosition;
    out.color = vertices[vertexID].color;

    return out;
}

// 片元着色器
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    return in.color;
}


