/// @func CheckSurface(_surface, _width, _height)
/// @desc Checks whether the surface exists and if it has correct size. Broken
/// surfaces are recreated. Surfaces of wrong size are resized.
/// @param {surface} _surface The surface to check.
/// @param {uint} _width The desired width of the surface.
/// @param {uint} _height The desired height of the surface.
/// @return {surface} The checked surface.
function CheckSurface(_surface, _width, _height)
{
	if (surface_exists(_surface))
	{
		if (surface_get_width(_surface) != _width
			|| surface_get_height(_surface) != _height)
		{
			surface_resize(_surface, _width, _height);
		}
	}
	else
	{
		_surface = surface_create(_width, _height);
	}
	return _surface;
}

/// @func BlurSurface(_surface, _scale[, _temp])
/// @desc Blurs the surface.
/// @param {surface} _surface The surface to blur.
/// @param {real} scale The scale of the blur kernel.
/// @param {surface} [_temp] A temporary surface. Must have the same size
/// as the target surface. If not specified, then a new one is created
/// and then freed at the end of the function.
function BlurSurface(_surface, _scale)
{
	var _surfaceW = surface_get_width(_surface);
	var _surfaceH = surface_get_height(_surface);
	var _texelW = _scale / _surfaceW;
	var _texelH = _scale / _surfaceH;

	var _temp;
	if (argument_count > 2)
	{
		_temp = argument[2];
	}
	else
	{
		_temp = surface_create(_surfaceW, _surfaceH);
	}

	var _shader = ShBlur;
	shader_set(_shader);

	shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), _texelW, 0);
	surface_set_target(_temp);
	draw_clear_alpha(0, 0);
	draw_surface(_surface, 0, 0);
	surface_reset_target();

	shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 0, _texelH);
	surface_set_target(_surface);
	draw_clear_alpha(0, 0);
	draw_surface(_temp, 0, 0);
	surface_reset_target();

	shader_reset();

	if (argument_count <= 2)
	{
		surface_free(_temp);
	}
}