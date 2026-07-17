varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	gl_FragColor = vec4(vec3(grey), col.a) * v_vColour;
}
