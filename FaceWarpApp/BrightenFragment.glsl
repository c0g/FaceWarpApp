// Interpolated values from the vertex shaders
varying lowp vec2 UV;
varying lowp float Brighten;

// Values that stay constant for the whole mesh.
uniform sampler2D TextureSampler;
uniform lowp float minimum;
uniform lowp float maximum;
uniform lowp float threshold;

void main(){
    lowp float dist = maximum - minimum;
    lowp float cutoff = minimum + dist * threshold;
    
    // Output color = color of the texture at the specified UV
    highp vec4 color = texture2D( TextureSampler, UV );
    highp float v = (color.r + color.b + color.g) * 0.3333333;
    if (v > cutoff) {
        color.rgb = color.rgb * Brighten;
    }
    gl_FragColor = color;
}