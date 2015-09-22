attribute vec4 Position;
attribute vec2 TexSource;

varying vec2 UV;

void main(void) {
    UV = TexSource;
    gl_Position = Position;
}