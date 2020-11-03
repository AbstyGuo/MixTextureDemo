attribute vec4 position;
attribute vec2 textCoordinate;
attribute vec2 textCoordinate1;
varying lowp vec2 varyTextCoord;
varying lowp vec2 varyTextCoord1;

void main()
{
    varyTextCoord = textCoordinate;
    varyTextCoord1 = textCoordinate1;
    gl_Position = position;
}
