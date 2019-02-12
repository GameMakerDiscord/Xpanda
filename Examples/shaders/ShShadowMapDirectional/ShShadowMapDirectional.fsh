varying vec2  v_vTexCoord;
varying float v_fDepth;

#pragma include("DepthEncoding.xsh", "glsl")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + c.y*inv255 + c.z*inv255*inv255;
}
// include("DepthEncoding.xsh")

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	if (base.a < 1.0)
	{
		discard;
	}
	gl_FragColor = vec4(xEncodeDepth(v_fDepth).xyz, 1.0);
}