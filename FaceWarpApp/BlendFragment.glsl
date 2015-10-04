// Interpolated values from the vertex shaders
varying lowp vec2 UV;
varying lowp float Alpha;

// Values that stay constant for the whole mesh.
uniform sampler2D TextureSampler;

void main(){
    
    // Output color = color of the texture at the specified UV
    highp vec4 color = texture2D( TextureSampler, UV );
    color.a = Alpha;
    gl_FragColor = color;
}