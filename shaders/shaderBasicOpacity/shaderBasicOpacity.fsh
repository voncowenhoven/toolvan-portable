// Very basic shader that changes the opacity of a layer by 0.5.
// This is used primarily by Toolvan because GameMaker does not have an inbuilt method for
// changing the opacity of an entire layer.

varying vec2 v_vTexcoord;

void main() {
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
    col.a *= 0.5;
    gl_FragColor = col;
}
