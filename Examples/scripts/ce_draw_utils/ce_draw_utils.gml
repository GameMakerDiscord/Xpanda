/// @func ce_draw_rectangle(_x, _y, _width, _height, _color[, _alpha])
/// @desc Draws a rectangle of the given size and color at the given position.
/// @param {real} _x The x position to draw the rectangle at.
/// @param {real} _y The y position to draw the rectangle at.
/// @param {real} _width The width of the rectangle.
/// @param {real} _height The height of the rectangle.
/// @param {real} _color The color of the rectangle.
/// @param {real} [_alpha] The alpha of the rectangle.
function ce_draw_rectangle(_x, _y, _width, _height, _color)
{
	var _alpha = (argument_count > 5) ? argument[5] : 1;
	draw_sprite_ext(CE_SprRectangle, 0, _x, _y, _width, _height, 0, _color, _alpha);
}

/// @func ce_draw_sprite_nine_slice(_sprite, _subimage, _x, _y, _width, _height, _tiled[, _color[, _alpha]])
/// @desc Draws a nine-slice sprite.
/// @param {real} _sprite The nine slice sprite to draw.
/// @param {real} _subimage The subimage of the sprite to draw.
/// @param {real} _x The x position to draw the sprite at.
/// @param {real} _y The y position to draw the sprite at.
/// @param {real} _width The width to which the sprite should be stretched.
/// @param {real} _height The height to which the sprite should be stretched.
/// @param {bool} _tiled True to tile the sprite of false to stretch.
/// @param {real} [_color] The color to blend the sprite with. Defaults to
/// `c_white`.
/// @param {real} [_alpha] The opacity of the sprite. Defaults to 1.
/// @note Currently it is not supported to use width and height smaller than
/// the size of the original image.
function ce_draw_sprite_nine_slice(_sprite, _subimage, _x, _y, _width, _height, _tiled)
{
	var _color = (argument_count > 7) ? argument[7] : c_white;
	var _alpha = (argument_count > 8) ? argument[8] : 1;

	var _sprite_width = sprite_get_width(_sprite);
	var _sprite_height = sprite_get_height(_sprite);

	var _slice_x = _sprite_width / 3;
	var _slice_x2 = _slice_x * 2;
	var _slice_y = _sprite_height / 3;
	var _slice_y2 = _slice_y * 2;

	_width = max(_width, _slice_x2);
	_height = max(_height, _slice_y2);

	var _width_inner = _width - _slice_x2;
	var _height_inner = _height - _slice_y2;

	var _scale_hor = _width_inner / _slice_x;
	var _scale_ver = _height_inner / _slice_y;

	var _center_x = _x + _slice_x;
	var _center_y = _y + _slice_y;
	var _right_x = _x + _width - _slice_x;
	var _bottom_y = _y + _height - _slice_y;

	if (!_tiled)
	{
		// Top edge
		draw_sprite_part_ext(_sprite, _subimage, _slice_x, 0,
			_slice_x, _slice_y, _center_x, _y, _scale_hor, 1, _color, _alpha);

		// Left edge
		draw_sprite_part_ext(_sprite, _subimage, 0, _slice_y,
			_slice_x, _slice_y, _x, _center_y, 1, _scale_ver, _color, _alpha);

		// Center
		draw_sprite_part_ext(_sprite, _subimage, _slice_x, _slice_y,
			_slice_x, _slice_y, _center_x, _center_y, _scale_hor, _scale_ver, _color, _alpha);

		// Right edge
		draw_sprite_part_ext(_sprite, _subimage, _slice_x2, _slice_y,
			_slice_x, _slice_y, _right_x, _center_y, 1, _scale_ver, _color, _alpha);

		// Bottom edge
		draw_sprite_part_ext(_sprite, _subimage, _slice_x, _slice_y2,
			_slice_x, _slice_y, _center_x, _bottom_y, _scale_hor, 1, _color, _alpha);
	}
	else
	{
		var _draw_x = _center_x;

		while (_draw_x < _center_x + _width_inner)
		{
			var _draw_y = _center_y;
			while (_draw_y < _center_y + _height_inner)
			{
				// Center
				draw_sprite_part_ext(_sprite, _subimage, _slice_x, _slice_y,
					_slice_x, _slice_y, _draw_x, _draw_y, 1, 1, _color, _alpha);
				_draw_y += _slice_y;
			}
			_draw_x += _slice_x;
		}

		_draw_x = _center_x;

		var _draw_y = _center_y;
		while (_draw_y < _center_y + _height_inner)
		{
			// Left edge
			draw_sprite_part_ext(_sprite, _subimage, 0, _slice_y,
				_slice_x, _slice_y, _x, _draw_y, 1, 1, _color, _alpha);
			// Right edge
			draw_sprite_part_ext(_sprite, _subimage, _slice_x2, _slice_y,
				_slice_x, _slice_y, _right_x, _draw_y, 1, 1, _color, _alpha);
			_draw_y += _slice_y;
		}

		while (_draw_x < _x + _width - _slice_x)
		{
			// Top edge
			draw_sprite_part_ext(_sprite, _subimage, _slice_x, 0,
				_slice_x, _slice_y, _draw_x, _y, 1, 1, _color, _alpha);

			// Bottom edge
			draw_sprite_part_ext(_sprite, _subimage, _slice_x, _slice_y2,
				_slice_x, _slice_y, _draw_x, _bottom_y, 1, 1, _color, _alpha);

			_draw_x += _slice_x;
		}
	}

	// Top left corner
	draw_sprite_part_ext(_sprite, _subimage, 0, 0,
		_slice_x, _slice_y, _x, _y, 1, 1, _color, _alpha);

	// Top right corner
	draw_sprite_part_ext(_sprite, _subimage, _slice_x2, 0,
		_slice_x, _slice_y, _right_x, _y, 1, 1, _color, _alpha);

	// Bottom left corner
	draw_sprite_part_ext(_sprite, _subimage, 0, _slice_x2,
		_slice_x, _slice_y, _x, _bottom_y, 1, 1, _color, _alpha);

	// Bottom right corner
	draw_sprite_part_ext(_sprite, _subimage, _slice_x2, _slice_y2,
		_slice_x, _slice_y, _right_x, _bottom_y, 1, 1, _color, _alpha);
}