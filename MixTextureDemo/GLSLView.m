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
    0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
    -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
    
    0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
    -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
    0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
};

@interface GLSLView ()

@property(nonatomic,strong) CAEAGLLayer *myEagLayer;
@property (nonatomic,strong) EAGLContext *glContext;

@property (nonatomic,assign) GLuint renderBuffer;
@property (nonatomic,assign) GLuint frameBuffer;

@property(nonatomic,assign)GLuint myProgram;

@property (nonatomic,assign) CGFloat mixAlpha;

@property (nonatomic,assign) GLuint texture1;
@property (nonatomic,assign) GLuint texture2;

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
    
    // 加载纹理代码需要放在设置上下文之后才会生效
    self.texture1 = [GLSLUtils createTextureWithImage:[UIImage imageNamed:@"1234"]];
    self.texture2 = [GLSLUtils createTextureWithImage:[UIImage imageNamed:@"2345"]];

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
        
    // 绑定并设置纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture1);
    glUniform1i(glGetUniformLocation(self.myProgram, "colorMap"), 0);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture2);
    glUniform1i(glGetUniformLocation(self.myProgram, "mixColor"), 1);

    // 使用顶点数组绘图
    glDrawArrays(GL_TRIANGLES, 0, 6);

    //13.从渲染缓存区显示到屏幕上
    [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
}

@end
