//
//  GLSLUtils.m
//  MixTextureDemo
//
//  Created by guoyf on 2020/11/3.
//

#import "GLSLUtils.h"

@implementation GLSLUtils

+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString{
    // 创建shader对象
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"Error: failed to create shader.");
        return 0;
    }
    
    // 加载shader的源码
    const char * shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    
    // 编译shader
    glCompileShader(shader);
    
    // 检查编译状态
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    // 编译失败
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1) {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog );
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}

+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath{
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderFilepath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (!shaderString) {
        NSLog(@"Error: loading shader file: %@ %@", shaderFilepath, error.localizedDescription);
        return 0;
    }
    
    return [self loadShader:type withString:shaderString];
}

+(GLuint)loadProgram:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath
{
    // 获取顶点着色器和片元着色器
    GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER
                              withFilepath:vertexShaderFilepath];
    if (vertexShader == 0)
        return 0;
    
    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER
                                withFilepath:fragmentShaderFilepath];
    if (fragmentShader == 0) {
        glDeleteShader(vertexShader);
        return 0;
    }
    
    // 创建program
    GLuint programHandle = glCreateProgram();
    if (programHandle == 0)
        return 0;
    
    // 添加着色器
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    // 连接项目
    glLinkProgram(programHandle);
    
    // 检查连接状态
    GLint linked;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linked);
    
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1){
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(programHandle, infoLen, NULL, infoLog);

            NSLog(@"Error linking program:\n%s\n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(programHandle );
        return 0;
    }
    
    // 释放不需要的资源
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return programHandle;
}




@end
