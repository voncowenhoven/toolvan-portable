// Very basic shader that changes the opacity of a layer by nothing.
// This is another Toolvan-specific shader because there is no way to just reset a single layer shader.

varying vec2 v_vTexcoord;

void main() {
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = vec4(col.rgb, col.a * 1.0);
}
