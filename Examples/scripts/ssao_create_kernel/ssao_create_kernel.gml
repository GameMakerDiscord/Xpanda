/// @func ssao_create_kernel(size)
/// @desc Generates a kernel of random vectors to be used for the SSAO.
/// @param {real} size Number of vectors in the kernel.
/// @return {array} The created kernel as `[v1X, v1Y, v1Z, v2X, v2Y, v2Z, ...,///                 vnX, vnY, vnZ]`.
var _kernel;
for (var i = argument0 - 1; i >= 0; --i)
{
	var _vec = vec3_create(random_range(-1, 1), random_range(-1, 1), random(1));
	vec3_normalize(_vec);
	var _s = i/argument0;
	_s = lerp(0.1, 1.0, _s*_s);
	vec3_scale(_vec, _s);
	var _i3 = i*3;
	_kernel[_i3 + 2] = _vec[2];
	_kernel[_i3 + 1] = _vec[1];
	_kernel[_i3]     = _vec[0];
}
return _kernel;