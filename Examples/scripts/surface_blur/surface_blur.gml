/// @func surface_blur(target, work, scale)
/// @desc Blurs the target surface.
/// @param {real} target The id of the surface to be blurred.
/// @param {real} work   The id of the working surface. Must have the same size
///                      as the target surface.
/// @param {real} scale  The scale of the blur kernel.
var _shader = ShBlur;
var _texelW = argument2/surface_get_width(argument0);
var _texelH = argument2/surface_get_height(argument0);

surface_set_target(argument1);
draw_clear_alpha(0, 0);
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), _texelW, 0.0);
draw_surface(argument0, 0, 0);
shader_reset();
surface_reset_target();

surface_set_target(argument0);
draw_clear_alpha(0, 0);
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 0.0, _texelH);
draw_surface(argument1, 0, 0);
shader_reset();
surface_reset_target();