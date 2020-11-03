//
//  GLSLUtils.h
//  MixTextureDemo
//
//  Created by guoyf on 2020/11/3.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLSLUtils : NSObject

/**
获取shader
 @param type  要加载的是顶点着色器还是片元着色器
 @param shaderString  着色器源码字符串
 @return 返回获取的shader的索引
 */
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

/**
获取shader
 @param type  要加载的是顶点着色器还是片元着色器
 @param shaderFilepath  着色器源码所在的文件路径
 @return 返回获取的shader的索引
 */
+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;

/**
获取program
 @param vertexShaderFilepath  要加载的顶点着色器路径
 @param fragmentShaderFilepath  要加载的片元着色器路径
 @return 返回获取的program的索引
 */
+(GLuint)loadProgram:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath;

@end

NS_ASSUME_NONNULL_END
