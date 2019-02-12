/// @func cubemap_to_single_surface(cubemap, surface)
/// @desc Puts all faces of the cubemap into a single surface.
/// @param {array} cubemap The cubemap.
/// @param {real}  surface The target surface (recreated or resized if
///                        necessary).
/// @return {real} The target surface.
var _size    = argument0[CUBEMAP_SIZE];
var _x       = 0;
var _surface = surface_check(argument1, _size * 8, _size);
surface_set_target(_surface);
draw_clear(c_red);
for (var i = 0; i < 6; ++i)
{
	draw_surface(argument0[i], _x, 0);
	_x += _size;
}
surface_reset_target();
return _surface;