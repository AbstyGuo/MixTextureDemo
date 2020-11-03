//
//  GLSLView.m
//  MixTextureDemo
//
//  Created by guoyf on 2020/11/2.
//

#import "GLSLView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLSLUtils.h"

//前3个是顶点坐标，后2个是纹理坐标
GLfloat attrArr[] =
{
    0.5f, -0.5f, -1.0f,     1.0f, 1.0f,
    -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,
    -0.5f, -0.5f, -1.0f,    0.0f, 1.0f,
    
    0.5f, 0.5f, -1.0f,      1.0f, 0.0f,
    -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,
    0.5f, -0.5f, -1.0f,     1.0f, 1.0f,
};

@interface GLSLView ()

@property(nonatomic,strong) CAEAGLLayer *myEagLayer;
@property (nonatomic,strong) EAGLContext *glContext;

@property (nonatomic,assign) GLuint renderBuffer;
@property (nonatomic,assign) GLuint frameBuffer;

@property(nonatomic,assign)GLuint myProgram;

@property (nonatomic,assign) CGFloat mixAlpha;

@end

@implementation GLSLView

- (void)awakeFromNib{
    [super awakeFromNib];
    _mixAlpha = 0.5;
}

- (IBAction)alphaChange:(UISlider *)sender {
    _mixAlpha = sender.value;
    [self drawLayer];
}

- (void)layoutSubviews{
    
    // 设置layer
    [self setUpLayer];
    
    // 设置上下文
    [self setupContext];
    
    // 清空缓存区
    [self clearBuffer];
    
    // 设置renderbuffer
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    // 开始绘制
    [self drawLayer];
}

- (void)setUpLayer{
    
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    
    // 设置scale
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    
    // 设置描述属性
    self.myEagLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking : @NO,
        kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
    };
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)setupContext{
    
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.glContext) {
        NSLog(@"Create Context failed!");
        return;
    }
    // 设置上下文
    if (![EAGLContext setCurrentContext:self.glContext]){
        NSLog(@"setCurrentContext failed");
        return;
    }
}

- (void)clearBuffer{
    glDeleteBuffers(1, &_renderBuffer);
    glDeleteBuffers(1, &_frameBuffer);
    
    self.renderBuffer = 0;
    self.frameBuffer = 0;
}

- (void)setupRenderBuffer{
    
    // 1、获取
    glGenRenderbuffers(1, &_renderBuffer);
    
    // 2、绑定
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderBuffer);
    
    // 3、设置上下文对象
    [self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}

- (void)setupFrameBuffer{
    // 1、获取
    glGenFramebuffers(1, &_frameBuffer);
    
    // 2、绑定
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    
    // 3、添加管理
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);
}

- (void)drawLayer{
    
    // 设置清屏颜色
    glClearColor(0.4, 0.9, 0.2, 0.8);
    // 清空缓存区
    glClear(GL_DEPTH_BITS | GL_COLOR_BUFFER_BIT);
    
    // 设置视口大小
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);

    //2.读取顶点着色程序、片元着色程序
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
    
    NSLog(@"vertFile:%@",vertFile);
    NSLog(@"fragFile:%@",fragFile);

    if (self.myProgram) {
        glDeleteProgram(self.myProgram);
        self.myProgram = 0;
    }
    
    self.myProgram = [GLSLUtils loadProgram:vertFile withFragmentShaderFilepath:fragFile];
        
    //处理program
    glLinkProgram(self.myProgram);
    
    GLint result;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &result);
    if (result == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.myProgram, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    
    NSLog(@"Program Link Success!");
    glUseProgram(self.myProgram);
    
    // 处理顶点数据
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    // 获取对应的属性
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL);
    
    // 处理纹理数据
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);
    
    GLuint textCoor1 = glGetAttribLocation(self.myProgram, "textCoordinate1");
    glEnableVertexAttribArray(textCoor1);
    glVertexAttribPointer(textCoor1, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL + 3);
    
    // 获取alpha变量
    GLuint alphaIndex = glGetUniformLocation(self.myProgram, "alpha");
    glUniform1f(alphaIndex, self.mixAlpha);    
    
    // 加载纹理,设置纹理采样器 sampler2D
    [self setupTexture:@"1234" location:0];
    glUniform1i(glGetUniformLocation(self.myProgram, "colorMap"), 0);

    [self setupTexture:@"2345" location:1];
    glUniform1i(glGetUniformLocation(self.myProgram, "mixColor"), 1);
    
    // 使用顶点数组绘图
    glDrawArrays(GL_TRIANGLES, 0, 6);

    //13.从渲染缓存区显示到屏幕上
    [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)setupTexture:(NSString *)fileName location:(GLuint)location {
    
    //1、将 UIImage 转换为 CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    //判断图片是否获取成功
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    //2、读取图片的大小，宽和高
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    //3.获取图片字节数 宽*高*4（RGBA）
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    //4.创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //5、在CGContextRef上--> 将图片绘制出来
    /*
     CGContextDrawImage 使用的是Core Graphics框架，坐标系与UIKit 不一样。UIKit框架的原点在屏幕的左上角，Core Graphics框架的原点在屏幕的左下角。
     CGContextDrawImage
     参数1：绘图上下文
     参数2：rect坐标
     参数3：绘制的图片
     */
    CGRect rect = CGRectMake(0, 0, width, height);
   
    //6.使用默认方式绘制
    CGContextDrawImage(spriteContext, rect, spriteImage);
   
    //7、画图完毕就释放上下文
    CGContextRelease(spriteContext);
    
    //8、绑定纹理到默认的纹理ID（
    glBindTexture(GL_TEXTURE_2D, location);
    
    //9.设置纹理属性
    /*
     参数1：纹理维度
     参数2：线性过滤、为s,t坐标设置模式
     参数3：wrapMode,环绕模式
     */
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    //10.载入纹理2D数据
    /*
     参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
     参数2：加载的层次，一般设置为0
     参数3：纹理的颜色值GL_RGBA
     参数4：宽
     参数5：高
     参数6：border，边界宽度
     参数7：format
     参数8：type
     参数9：纹理数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    //11.释放spriteData
    free(spriteData);
    return 0;
}

@end
