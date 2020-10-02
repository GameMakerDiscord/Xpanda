/// @func DrawTextShadow(_x, _y, _string[, _color[, _shadow]])
/// @param {real} _x
/// @param {real} _y
/// @param {string} _string
/// @param {uint} [_color]
/// @param {uint} [_shadow]
function DrawTextShadow(_x, _y, _string)
{
	var _color = (argument_count > 3) ? argument[3] : c_white;
	var _shadow = (argument_count > 4) ? argument[4] : c_black;
	draw_text_color(_x + 1, _y + 1, _string, _shadow, _shadow, _shadow, _shadow, 1);
	draw_text_color(_x, _y, _string, _color, _color, _color, _color, 1);
}