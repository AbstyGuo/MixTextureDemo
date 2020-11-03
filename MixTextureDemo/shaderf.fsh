precision highp float;
varying lowp vec2 varyTextCoord;
varying lowp vec2 varyTextCoord1;
uniform float alpha;
uniform sampler2D colorMap;
uniform sampler2D mixColor;

void main()
{
    vec4 textureColor = texture2D(colorMap,varyTextCoord);
    vec4 color = texture2D(mixColor,varyTextCoord1);
    gl_FragColor = mix(textureColor,color,alpha);
}
