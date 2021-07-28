//> Size of the noise texture. Must be the same value as in the xSsaoInit script!
#define X_SSAO_NOISE_TEXTURE_SIZE 4

varying vec2 v_vTexCoord;

uniform vec2 u_vTexel; // (1/screenWidth,0) for horizontal blur, (0,1/screenHeight) for vertical

void main()
{
	gl_FragColor = vec4(0.0);
	float size   = float(X_SSAO_NOISE_TEXTURE_SIZE);
	for (float i = 0.0; i < size; i += 1.0)
	{
		gl_FragColor += texture2D(gm_BaseTexture, v_vTexCoord + u_vTexel * i);
	}
	gl_FragColor /= size;
}