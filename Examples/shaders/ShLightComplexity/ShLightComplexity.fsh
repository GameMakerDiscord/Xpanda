varying vec2 v_vTexCoord;

void main()
{
	vec3 hotness[5];
	hotness[0] = vec3(0.0);
	hotness[1] = vec3(0.0, 0.0, 1.0);
	hotness[2] = vec3(0.0, 1.0, 0.0);
	hotness[3] = vec3(1.0, 1.0, 0.0);
	hotness[4] = vec3(1.0, 0.0, 0.0);

	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	int lightCount = ((base.r > 0.0) ? 1 : 0)
		+ ((base.g > 0.0) ? 1 : 0)
		+ ((base.b > 0.0) ? 1 : 0)
		+ ((base.a > 0.0) ? 1 : 0);
	gl_FragColor.rgb = hotness[lightCount];
	gl_FragColor.a = (lightCount > 0) ? 0.25 : 0.0;
}