//
//  annotation.h
//  MixTextureDemo
//
//  Created by guoyf on 2020/11/3.
//

#ifndef annotation_h
#define annotation_h

/**
  默认纹理加载出来是反着的，有5中处理方式
 
 1、设置转置矩阵，给图片添加旋转
 -(void)rotateTextureImage
 {
     //注意，想要获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
     //1. rotate等于shaderv.vsh中的uniform属性，rotateMatrix
     GLuint rotate = glGetUniformLocation(self.myPrograme, "rotateMatrix");
     
     //2.获取渲旋转的弧度
     float radians = 180 * 3.14159f / 180.0f;
    
     //3.求得弧度对于的sin\cos值
     float s = sin(radians);
     float c = cos(radians);
     
     //4.因为在3D课程中用的是横向量，在OpenGL ES用的是列向量
     
    //参考Z轴旋转矩阵
      
     GLfloat zRotation[16] = {
         c,-s,0,0,
         s,c,0,0,
         0,0,1,0,
         0,0,0,1
     };
     
     //5.设置旋转矩阵
      glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
      location : 对于shader 中的ID
      count : 个数
      transpose : 转置
      value : 指针
     glUniformMatrix4fv(rotate, 1, GL_FALSE, zRotation);
 }
 
 2、加载图片的时候给图片添加旋转（当前的GLSLUtils中用的就是这种方法）
 CGContextTranslateCTM(context, 0, height);
 CGContextScaleCTM(context, 1.0f, -1.0f);
 
 3、在片元着色器的源码中添加旋转
 原来：
 vec4 textureColor = texture2D(colorMap,varyTextCoord);
 改为：
 vec4 textureColor = texture2D(colorMap,vec2(varyTextCoord.x,1.0-varyTextCoord.y));

 4、在顶点着色器的源码中添加旋转
 原来：
    varyTextCoord = textCoordinate;
 改为：
    varyTextCoord = vec2(textCoordinate.x,1.0-textCoordinate.y);

 5、在添加顶点数组的时候，对应的纹理位置按倒置位置对应
 原来：
    GLfloat attrArr[] =
    {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,

        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };

 改为：
     GLfloat attrArr[] =
     {
         0.5f, -0.5f, -1.0f,     1.0f, 1.0f,
         -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,
         -0.5f, -0.5f, -1.0f,    0.0f, 1.0f,
         
         0.5f, 0.5f, -1.0f,      1.0f, 0.0f,
         -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,
         0.5f, -0.5f, -1.0f,     1.0f, 1.0f,
     };

 
 */

#endif /* annotation_h */
