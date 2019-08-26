//
//  ViewController.m
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//
@import MetalKit;
#import "LYShaderTypes.h"
#import "ViewController.h"

@interface ViewController () <MTKViewDelegate>

// view
@property (nonatomic, strong) MTKView *mtkView;

// data
@property (nonatomic, assign) vector_uint2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLBuffer> vertices;
@property (nonatomic, assign) NSUInteger numVertices;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self customInit];
}

- (void)customInit {
    
    // 初始化 MTKView
    [self setupMTKView];
    
    // 设置渲染管道
    [self setupPipeline];
    
    // 设置顶点数据
    [self setupVertex];
    
    // 设置纹理数据
    [self setupTexture];
}

- (void)setupMTKView {
    // MTLDevice - 代表GPU设备，提供创建缓存、纹理等的接口
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (device == nil) {
        NSLog(@"don't support metal !");
        return;
    }
    
    // 初始化 MTKView - 要用 Metal 来直接绘制的话，需要用特殊的界面 MTKView
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    // 给 MTKView 设置获取到的 device
    self.mtkView.device = device;
    self.view = self.mtkView;
    self.mtkView.delegate = self;
    
    // 当前显示区域size
    self.viewportSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
}

// 设置渲染管道
-(void)setupPipeline {
    // MTLLibrary 代表整个 Metal 的函数库 所有的 .metal结尾的文件
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary]; // .metal
    
    
    // 获取顶点着色器 所有的 .metal 文件里的
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"]; // 顶点shader，vertexShader是函数名
    
    // 获取片元着色器
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"]; // 片元shader，samplingShader是函数名
    
    // MTLRenderPipelineDescriptor - 是渲染管道的描述符，可以设置顶点处理函数、片元处理函数、输出颜色格式等
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                         error:NULL]; // 创建图形渲染管道，耗性能操作不宜频繁调用,可重用
    
    // 创建的是指令队列，用来存放渲染的指令
    self.commandQueue = [self.mtkView.device newCommandQueue]; // CommandQueue是渲染指令队列，保证渲染指令有序地提交到GPU
}

// 设置顶点数据
- (void)setupVertex {

    /*
     顶点数据里包括顶点坐标，metal的世界坐标系与OpenGL ES一致，范围是[-1, 1]，故而点(0, 0)是在屏幕的正中间；
                (1)
                |
                |
    ---(-1)-----|-----(1)---
                |
                |
                (-1)
     
     | (1)
     |
     |
     |
     |—————————(1)
     (0)
     
     顶点数据里还包括纹理坐标，纹理坐标系的取值范围是[0, 1]，原点是在左下角； 纹理坐标，x、y；
     
     
     在 Metal 里面代表顶点需要 4 个 float ，顶点坐标 x，y，z，w。最后二位我们绘制 2D 界面的时候默认为0.0 和 1.0，w 是为了方便 3D 计算的。
     
     
     [device newBufferWithBytes:quadVertices..]创建的是顶点缓存，类似OpenGL ES的glGenBuffer创建的缓存。
    */
    
    
    // original
    static const LYVertex quadVertices[] =
    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -0.5, -0.5, 0.0, 1.0 },  { 0.f, 1.f } },
        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 0.f } },

        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 0.f } },
        { {  0.5,  0.5, 0.0, 1.0 },  { 1.f, 0.f } },
    };
    
    
    // test_1
//    static const LYVertex quadVertices[] =
//    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
//        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
//        { { -1.0, -1.0, 0.0, 1.0 },  { 0.f, 1.f } },
//        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
//
//        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 1.f } },
//        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 0.f } },
//        { {  0.5,  0.5, 0.0, 1.0 },  { 1.f, 0.f } },
//    };
    
    // test_2
//    static const LYVertex quadVertices[] =
//    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
//        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
//        { { -1.0, -1.0, 0.0, 1.0 },  { 0.f, 1.f } },
//        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
//
//        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
//        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
//        { {  1.0,  1.0, 0.0, 1.0 },  { 1.f, 0.f } },
//    };
    
    
    
    // test_3
//    static const LYVertex quadVertices[] =
//    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
//        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 0.f } },
//        { { -1.0, -1.0, 0.0, 1.0 },  { 0.f, 0.f } },
//        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 1.f } },
//
//        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 1.f } },
//        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 0.f } },
//        { {  0.5,  0.5, 0.0, 1.0 },  { 1.f, 0.f } },
//    };
    
    // test_4
//    static const LYVertex quadVertices[] =
//    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
//        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 0.f } },
//        { { -1.0, -1.0, 0.0, 1.0 },  { 0.f, 0.f } },
//        { { -1.0,  1.0, 0.0, 1.0 },  { 1.f, 1.f } },
//
//        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 1.f } },
//        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 0.f } },
//        { {  0.5,  0.5, 0.0, 1.0 },  { 1.f, 0.f } },
//    };
    
    // test_5 color
//    static const LYVertex quadVertices[] =
//    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
//        { {  0.5, -0.5, 0.0, 1.0 },  {1.f, 0.f, 0.f},  { 1.f, 1.f } },
//        { { -0.5, -0.5, 0.0, 1.0 },  {0.f, 1.f, 0.f},  { 0.f, 1.f } },
//        { { -0.5,  0.5, 0.0, 1.0 },  {0.f, 0.f, 1.f},  { 0.f, 0.f } },
//
//        { {  0.5, -0.5, 0.0, 1.0 },  {1.f, 0.f, 0.f}, { 1.f, 1.f } },
//        { { -0.5,  0.5, 0.0, 1.0 },  {0.f, 1.f, 0.f}, { 0.f, 0.f } },
//        { {  0.5,  0.5, 0.0, 1.0 },  {0.f, 0.f, 1.f}, { 1.f, 0.f } },
//    };


    
    self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                 length:sizeof(quadVertices)
                                                options:MTLResourceStorageModeShared]; // 创建顶点缓存
    self.numVertices = sizeof(quadVertices) / sizeof(LYVertex); // 顶点个数
}

// 设置纹理数据
- (void)setupTexture {
    
    /*
     MTLTextureDescriptor是纹理数据的描述符，可以设置像素颜色格式、图像宽高等，用于创建纹理；
     
     纹理创建完毕后，需要用-replaceRegion: mipmapLevel:withBytes:bytesPerRow:接口上传纹理数据；
     
     MTLRegion类似UIKit的frame，用于表明纹理数据的存放区域；
     */
    
    
    
    UIImage *image = [UIImage imageNamed:@"test_1"];
    // 纹理描述符
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDescriptor.width = image.size.width;
    textureDescriptor.height = image.size.height;
    self.texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor]; // 创建纹理
    
    MTLRegion region = {{ 0, 0, 0 }, {image.size.width, image.size.height, 1}}; // 纹理上传的范围
    Byte *imageBytes = [self loadImage:image];
    if (imageBytes) { // UIImage的数据需要转成二进制才能上传，且不用jpg、png的NSData
        [self.texture replaceRegion:region
                    mipmapLevel:0
                      withBytes:imageBytes
                    bytesPerRow:4 * image.size.width];
        free(imageBytes); // 需要释放资源
        imageBytes = NULL;
    }
}

- (Byte *)loadImage:(UIImage *)image {
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = image.CGImage;
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    Byte * spriteData = (Byte *) calloc(width * height * 4, sizeof(Byte)); //rgba共4个byte
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    return spriteData;
}



#pragma mark - delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    self.viewportSize = (vector_uint2){size.width, size.height};
}

// 具体渲染过程
- (void)drawInMTKView:(MTKView *)view {
    /*
     drawInMTKView:方法是MetalKit每帧的渲染回调，可以在内部做渲染的处理；
     
     绘制的第一步是从commandQueue里面创建commandBuffer，
     commandQueue是整个app绘制的队列，
     而commandBuffer存放每次渲染的指令，
     commandQueue内部存在着多个commandBuffer。
     
     整个绘制的过程与OpenGL ES一致：
     1、先设置窗口大小
     2、然后设置顶点数据和纹理
     3、最后绘制两个三角形。
     
     */
    
    
    // 每次渲染都要单独创建一个CommandBuffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    // MTLRenderPassDescriptor描述一系列attachments的值，类似GL的FrameBuffer；同时也用来创建MTLRenderCommandEncoder
    if(renderPassDescriptor != nil)
    {
        // 用颜色清除当前画布，就是把当前画布设置为该颜色
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0f); // 设置默认颜色
        
        
        /*
         有了资源文件，渲染管线之后，我们可以开始做最后的步骤了，构造 MTLCommandEncoder 编码器。指令编码器包括 渲染 计算 位图复制三种编码器。
         
         MTLRenderCommandEncoder 渲染 3D 编码器
         MTLComputeCommandEncoder 计算编码器
         MTLBlitCommandEncoder 位图复制编码器 拷贝 buffer texture 同时也能生成 mipmap(mipmap 指的是一种纹理映射技术)
         
         
         */
        
        
        // 这里我们是为了渲染一个三角形，所以这里用的是 MTLRenderCommandEncoder
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor]; //编码绘制指令的Encoder
        
        // 设置显示区域 - originX, originY, width, height, znear, zfar;
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }]; // 设置显示区域
        [renderEncoder setRenderPipelineState:self.pipelineState]; // 设置渲染管道，以保证顶点和片元两个shader会被调用
        
        [renderEncoder setVertexBuffer:self.vertices
                                offset:0
                               atIndex:0]; // 设置顶点缓存

        [renderEncoder setFragmentTexture:self.texture
                                  atIndex:0]; // 设置纹理
        
        // 设置渲染的顶点配置（这里设置为三角 从第一个顶点开始取 取 3 个
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:self.numVertices]; // 绘制
        
        [renderEncoder endEncoding]; // 结束
        
        [commandBuffer presentDrawable:view.currentDrawable]; // 显示
    }
    
    [commandBuffer commit]; // 提交；
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
