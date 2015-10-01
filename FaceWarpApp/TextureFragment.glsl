// Interpolated values from the vertex shaders
varying lowp vec2 UV;

// Values that stay constant for the whole mesh.
uniform sampler2D TextureSampler;

void main(){
    
    // Output color = color of the texture at the specified UV
    gl_FragColor = texture2D( TextureSampler, UV );
}