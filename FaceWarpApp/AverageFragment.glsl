/* BlurFragmentShader.glsl */

varying lowp vec2 v_blurTexCoords[2];

// Interpolated values from the vertex shaders
varying lowp vec2 UV;
varying lowp float Alpha;

// Values that stay constant for the whole mesh.
uniform sampler2D TextureSampler;

void main()
{
    gl_FragColor = vec4(0.0);
    gl_FragColor += texture2D(TextureSampler, v_blurTexCoords[ 0])*0.33333;
    gl_FragColor += texture2D(TextureSampler, UV                 )*0.33333;
    gl_FragColor += texture2D(TextureSampler, v_blurTexCoords[ 1])*0.33333;
    gl_FragColor.a = Alpha;
}