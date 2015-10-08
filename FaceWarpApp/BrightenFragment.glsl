// Interpolated values from the vertex shaders
varying lowp vec2 UV;
varying lowp float Brighten;

// Values that stay constant for the whole mesh.
uniform sampler2D TextureSampler;
uniform lowp float minimum;
uniform lowp float maximum;
uniform highp float threshold;

void main(){
    lowp float dist = maximum - minimum;
    lowp float cutoff = minimum + dist * threshold;
    
    // Output color = color of the texture at the specified UV
    highp vec4 color = texture2D( TextureSampler, UV );
    
    highp float m = min(color.r, min(color.b, color.g));
    highp float M = max(color.r, max(color.b, color.g));
    highp float C = M - m;
    if (C > 0.0) {
        highp float v = (color.r + color.b + color.g) / 3.0;
        highp float S = C / v;
        highp float amount = min(1.0, max(0.0, 1.0 - S));
        color.rgb += color.rgb * Brighten * amount;
    }

    gl_FragColor = color;
}