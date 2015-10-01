//
//  Texture.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

class Texture {
    var name : GLuint = GLuint()
    var target : GLuint = GLuint()
    
    init() {
        // Create a texture in OpenGL land
        name = 0
        target = 0
    }
    
    init(withName _name: GLuint, andTarget _target: GLuint) {
        // We already have a texture, just want to wrap it
        name = _name;
        target = _target;
    }
    
    func attachToTextureUnit() {
        
    }
    
}