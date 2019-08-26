//
//  ViewController.m
//  一个简单的metal应用
//
//  Created by Beauty-jishu on 2018/8/29.
//  Copyright © 2018年 码叔. All rights reserved.
//

#import "ViewController.h"
// Metal API
#import <Metal/Metal.h>
#import <simd/simd.h>
#import <MetalKit/MetalKit.h>


// 定义一个顶点信息：顶点位置+顶点颜色
typedef struct
{
    vector_float2 position;
    vector_float4 color;
} Vertex;

@interface ViewController () <MTKViewDelegate>

@end

@implementation ViewController {
    MTKView *_mtkView;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLRenderPipelineState> _renderPipelineState;
    vector_uint2 _viewPortSize;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup Metal Device
    _device = MTLCreateSystemDefaultDevice();
    if(!_device) {
        NSLog(@"获取Metal设备失败");
    }
    _mtkView = [[MTKView alloc] initWithFrame:self.view.frame device:_device];
    _mtkView.delegate = self;
    [self mtkView:_mtkView drawableSizeWillChange:_mtkView.drawableSize];
    [self.view addSubview:_mtkView];

    id <MTLLibrary> library = [_device newDefaultLibrary];
    id <MTLFunction> vertexShader = [library newFunctionWithName:@"vertexShader"];
    id <MTLFunction> fragmentShader = [library newFunctionWithName:@"fragmentShader"];

    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.vertexFunction = vertexShader;
    pipelineDescriptor.fragmentFunction = fragmentShader;
    pipelineDescriptor.colorAttachments[0].pixelFormat = _mtkView.colorPixelFormat;

    NSError *error;
    _renderPipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if(error) {
        NSLog(@"创建管线失败");
        return;
    }

    _commandQueue = [_device newCommandQueue];
}

#pragma mark MTKViewDelegate

// 每一帧被回调
- (void)drawInMTKView:(nonnull MTKView *)view {

    _mtkView.clearColor = MTLClearColorMake(0.4, 0.2, 0.3, 1.0);

    static const Vertex triangleVertices[] =
            {
                    // 2D positions,    RGBA colors
                    { {  0.5,  -0.5 }, { 1, 0, 0, 1 } },
                    { { -0.5,  -0.5 }, { 0, 1, 0, 1 } },
                    { {    0,   0.5 }, { 0, 0, 1, 1 } },
            };
    // 每次渲染都重新从渲染队列中获取一个命令缓冲，该命令缓冲不复用
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];

    MTLRenderPassDescriptor *renderPassDescriptor = _mtkView.currentRenderPassDescriptor;
    // 获取渲染命令编码器
    id <MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    // 渲染命令编码器需要绑定管线状态
    [renderCommandEncoder setRenderPipelineState:_renderPipelineState];
    // 设置视口大小
    [renderCommandEncoder setViewport:(MTLViewport){0, 0, _viewPortSize.x, _viewPortSize.y, -1, 1}];
    // 编码顶点数据
    [renderCommandEncoder setVertexBytes:triangleVertices
                           length:sizeof(triangleVertices)
                          atIndex:0];

    // 编码绘制三角形命令
    [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                      vertexStart:0
                      vertexCount:3];
    // 结束编码
    [renderCommandEncoder endEncoding];
    // 指定输出
    [commandBuffer presentDrawable:_mtkView.currentDrawable];
    // 提交命令
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewPortSize.x = size.width;
    _viewPortSize.y = size.height;
}



@end
