//
//  Shader.fsh
//  CeedGLDemo
//
//  Created by Raphael Sebbe on 07/11/10.
//  Copyright 2010 Creaceed. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
