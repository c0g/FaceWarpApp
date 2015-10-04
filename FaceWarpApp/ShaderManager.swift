//
//  Shaders.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

class ShaderManager {
    
    let passThroughShader : ShaderProgram
    let passThroughXYZ : GLuint
    let passThroughUV : GLuint
    let passThroughTex : GLint
    
    let hblurShader : ShaderProgram
    let hblurXYZ : GLuint
    let hblurUV : GLuint
    let hblurScale : GLint
    let hblurTex : GLint
    
    let vblurShader : ShaderProgram
    let vblurXYZ : GLuint
    let vblurUV : GLuint
    let vblurScale : GLint
    let vblurTex : GLint
    
    init?() {
        passThroughShader = ShaderProgram(withVertexShader: "TextureVertex", andFragmentShader: "TextureFragment")!
        passThroughXYZ = GLuint(glGetAttribLocation(passThroughShader.programHandle, "Position"))
        passThroughUV = GLuint(glGetAttribLocation(passThroughShader.programHandle, "TexSource"))
        passThroughTex = GLint(glGetUniformLocation(passThroughShader.programHandle, "TextureSampler"))
        glEnableVertexAttribArray(passThroughXYZ)
        glEnableVertexAttribArray(passThroughUV)
        
        hblurShader = ShaderProgram(withVertexShader: "GaussianHorizontalVertex", andFragmentShader: "GaussianFragment")!
        hblurXYZ = GLuint(glGetAttribLocation(hblurShader.programHandle, "Position"))
        hblurUV = GLuint(glGetAttribLocation(hblurShader.programHandle, "TexSource"))
        hblurScale = GLint(glGetUniformLocation(hblurShader.programHandle, "Scale"))
        hblurTex = GLint(glGetUniformLocation(hblurShader.programHandle, "TextureSampler"))
        glEnableVertexAttribArray(hblurXYZ)
        glEnableVertexAttribArray(hblurUV)
        
        vblurShader = ShaderProgram(withVertexShader: "GaussianVerticalVertex", andFragmentShader: "GaussianFragment")!
        vblurXYZ = GLuint(glGetAttribLocation(vblurShader.programHandle, "Position"))
        vblurUV = GLuint(glGetAttribLocation(vblurShader.programHandle, "TexSource"))
        vblurScale = GLint(glGetUniformLocation(vblurShader.programHandle, "Scale"))
        vblurTex = GLint(glGetUniformLocation(vblurShader.programHandle, "TextureSampler"))
        glEnableVertexAttribArray(vblurXYZ)
        glEnableVertexAttribArray(vblurUV)
    }
    
    func activatePassThroughShader() -> (GLuint, GLuint, GLint) {
        glUseProgram(passThroughShader.programHandle)
        return (passThroughXYZ, passThroughUV, passThroughTex)
    }
    
    func activateHBlurShader(WithScale scale : GLfloat) -> (GLuint, GLuint, GLint) {
        glUseProgram(hblurShader.programHandle)
        glUniform1f(hblurScale, scale)
        return (hblurXYZ, hblurUV, hblurTex)
    }
    
    func activateVBlurShader(WithScale scale : GLfloat) -> (GLuint, GLuint, GLint) {
        glUseProgram(vblurShader.programHandle)
        glUniform1f(vblurScale, scale)
        return (vblurXYZ, vblurUV, vblurTex)
    }
    
    
    
}
//
//func compileShader(shaderName: String, shaderType: GLenum) -> GLuint {
//    
//    // Get NSString with contents of our shader file.
//    let shaderPath: String! = NSBundle.mainBundle().pathForResource(shaderName, ofType: "glsl")
//    var shaderString: NSString?
//    do {
//        shaderString = try NSString(contentsOfFile:shaderPath, encoding: NSUTF8StringEncoding)
//    } catch let error as NSError {
//        print(error)
//        shaderString = nil
//    }
//    if (shaderString == nil) {
//        print("Failed to set contents shader of shader file!")
//    }
//    
//    // Tell OpenGL to create an OpenGL object to represent the shader, indicating if it's a vertex or a fragment shader.
//    let shaderHandle: GLuint = glCreateShader(shaderType)
//    
//    if shaderHandle == 0 {
//        NSLog("Couldn't create shader")
//    }
//    // Conver shader string to CString and call glShaderSource to give OpenGL the source for the shader.
//    var shaderStringUTF8 = shaderString!.UTF8String
//    var shaderStringLength: GLint = GLint(Int32(shaderString!.length))
//    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength)
//    
//    // Tell OpenGL to compile the shader.
//    glCompileShader(shaderHandle)
//    
//    // But compiling can fail! If we have errors in our GLSL code, we can here and output any errors.
//    var compileSuccess: GLint = GLint()
//    glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
//    if (compileSuccess == GL_FALSE) {
//        print("Failed to compile shader \(shaderName)!")
//        // TODO: Actually output the error that we can get from the glGetShaderInfoLog function.
//        var infolog = [GLchar](count: 100, repeatedValue: 0)
//        var length : GLsizei = GLsizei()
//        glGetShaderInfoLog(shaderHandle, 100, &length, &infolog)
//        print(String.fromCString(&infolog))
//        exit(1);
//    }
//    
//    return shaderHandle
//}
//
//func compileShaders() {
//    
//    // Compile our vertex and fragment shaders.
//    let vertexShader: GLuint = self.compileShader("TextureVertex", shaderType: GLenum(GL_VERTEX_SHADER))
//    let fragmentShader: GLuint = self.compileShader("TextureFragment", shaderType: GLenum(GL_FRAGMENT_SHADER))
//    
//    
//    activateStandardShader()
//}
//
//func activateStandardShader() {
//    // Call glUseProgram to tell OpenGL to actually use this program when given vertex info.
//    glUseProgram(programHandle)
//    
//    // Finally, call glGetAttribLocation to get a pointer to the input values for the vertex shader, so we
//    //  can set them in code. Also call glEnableVertexAttribArray to enable use of these arrays (they are disabled by default).
//    self.positionSlot = GLuint(glGetAttribLocation(programHandle, "Position"))
//    self.uvSlot = GLuint(glGetAttribLocation(programHandle, "TexSource"))
//    glEnableVertexAttribArray(self.positionSlot)
//    glEnableVertexAttribArray(self.uvSlot)
//    
//    self.textureSlot = GLint(glGetUniformLocation(programHandle, "TextureSampler"));
//    //Attach uniform in textureSlot to TEXTURE0
//    glUniform1i(self.textureSlot, 0);
//}
//
//func compileBlurShaders() {
//    
//    // Compile our vertex and fragment shaders.
//    let gaussianHorizontalVertexShader: GLuint = self.compileShader("GaussianHorizontalVertex", shaderType: GLenum(GL_VERTEX_SHADER))
//    let gaussianVerticalVertexShader: GLuint = self.compileShader("GaussianVerticalVertex", shaderType: GLenum(GL_VERTEX_SHADER))
//    let gaussianFragment: GLuint = self.compileShader("GaussianFragment", shaderType: GLenum(GL_FRAGMENT_SHADER))
//    
//    // Call glCreateProgram, glAttachShader, and glLinkProgram to link the vertex and fragment shaders into a complete program.
//    gaussianHorizontalProgramHandle = glCreateProgram()
//    glAttachShader(gaussianHorizontalProgramHandle, gaussianHorizontalVertexShader)
//    glAttachShader(gaussianHorizontalProgramHandle, gaussianFragment)
//    glLinkProgram(gaussianHorizontalProgramHandle)
//    
//    // Call glCreateProgram, glAttachShader, and glLinkProgram to link the vertex and fragment shaders into a complete program.
//    gaussianVerticalProgramHandle = glCreateProgram()
//    glAttachShader(gaussianVerticalProgramHandle, gaussianVerticalVertexShader)
//    glAttachShader(gaussianVerticalProgramHandle, gaussianFragment)
//    glLinkProgram(gaussianVerticalProgramHandle)
//    
//    // Check for any errors.
//    var linkSuccess: GLint = GLint()
//    glGetProgramiv(gaussianHorizontalProgramHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
//    if (linkSuccess == GL_FALSE) {
//        print("Failed to create Gaussian Horizontal shader program!")
//        var infolog = [GLchar](count: 100, repeatedValue: 0)
//        var length : GLsizei = GLsizei()
//        glGetProgramInfoLog(gaussianHorizontalProgramHandle, 100, &length, &infolog)
//        print(String.fromCString(&infolog))
//        exit(1);
//    }
//    
//    // Call glCreateProgram, glAttachShader, and glLinkProgram to link the vertex and fragment shaders into a complete program.
//    gaussianVerticalProgramHandle = glCreateProgram()
//    glAttachShader(gaussianVerticalProgramHandle, gaussianHorizontalVertexShader)
//    glAttachShader(gaussianVerticalProgramHandle, gaussianFragment)
//    glLinkProgram(gaussianVerticalProgramHandle)
//    
//    // Check for any errors.
//    linkSuccess = GLint()
//    glGetProgramiv(gaussianVerticalProgramHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
//    if (linkSuccess == GL_FALSE) {
//        print("Failed to create Gaussian Vertical shader program!")
//        var infolog = [GLchar](count: 100, repeatedValue: 0)
//        var length : GLsizei = GLsizei()
//        glGetProgramInfoLog(gaussianVerticalProgramHandle, 100, &length, &infolog)
//        print(String.fromCString(&infolog))
//        exit(1);
//    }
//    
//}
//
//func activateHorizontalBlurShader() {
//    // Call glUseProgram to tell OpenGL to actually use this program when given vertex info.
//    glUseProgram(gaussianHorizontalProgramHandle)
//    
//    // Finally, call glGetAttribLocation to get a pointer to the input values for the vertex shader, so we
//    //  can set them in code. Also call glEnableVertexAttribArray to enable use of these arrays (they are disabled by default).
//    self.positionSlot = GLuint(glGetAttribLocation(gaussianHorizontalProgramHandle, "Position"))
//    self.uvSlot = GLuint(glGetAttribLocation(gaussianHorizontalProgramHandle, "TexSource"))
//    glEnableVertexAttribArray(self.positionSlot)
//    glEnableVertexAttribArray(self.uvSlot)
//    
//    self.scaleSlot = GLint(glGetUniformLocation(gaussianHorizontalProgramHandle, "Scale"));
//    setScaleInShader(gaussianHorizontalProgramHandle, toValue: 0.1)
//    
//    self.textureSlot = GLint(glGetUniformLocation(gaussianHorizontalProgramHandle, "TextureSampler"));
//    //Attach uniform in textureSlot to TEXTURE0
//    glUniform1i(self.textureSlot, 0);
//}
//
//func activateVerticalBlurShader() {
//    // Call glUseProgram to tell OpenGL to actually use this program when given vertex info.
//    glUseProgram(gaussianVerticalProgramHandle)
//    
//    // Finally, call glGetAttribLocation to get a pointer to the input values for the vertex shader, so we
//    //  can set them in code. Also call glEnableVertexAttribArray to enable use of these arrays (they are disabled by default).
//    self.positionSlot = GLuint(glGetAttribLocation(gaussianVerticalProgramHandle, "Position"))
//    self.uvSlot = GLuint(glGetAttribLocation(gaussianVerticalProgramHandle, "TexSource"))
//    glEnableVertexAttribArray(self.positionSlot)
//    glEnableVertexAttribArray(self.uvSlot)
//    
//    self.scaleSlot = GLint(glGetUniformLocation(gaussianVerticalProgramHandle, "Scale"));
//    setScaleInShader(gaussianVerticalProgramHandle, toValue: 1)
//    
//    self.textureSlot = GLint(glGetUniformLocation(gaussianVerticalProgramHandle, "TextureSampler"));
//    //Attach uniform in textureSlot to TEXTURE0
//    glUniform1i(self.textureSlot, 0);
//}
//
//func setScaleInShader(shader : GLuint, toValue v : Float32) {
//    let loc : GLint = glGetUniformLocation(shader, "Scale");
//    if (loc != -1)
//    {
//        glUniform1f(loc, v);
//    }
//}