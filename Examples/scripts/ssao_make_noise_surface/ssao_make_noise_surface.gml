/// @func ssao_make_noise_surface(size)
/// @desc Creates a surface containing a random noise for the SSAO.
/// @param {real} size Size of the noise surface.
/// @return {real} The created noise surface.
function ssao_make_noise_surface(argument0) {
	var _sur = surface_create(argument0, argument0);
	surface_set_target(_sur);
	draw_clear(0);
	for (var i = 0; i < argument0; ++i)
	{
		for (var j = 0; j < argument0; ++j)
		{
			var _vec = vec3_create(random_range(-1, 1), random_range(-1, 1), 0);
			vec3_normalize(_vec);
			var _col = make_colour_rgb(
				(_vec[0] * 0.5 + 0.5) * 255,
				(_vec[1] * 0.5 + 0.5) * 255,
				(_vec[2] * 0.5 + 0.5) * 255);
			draw_point_colour(i, j, _col);
		}
	}
	surface_reset_target();
	return _sur;


}
