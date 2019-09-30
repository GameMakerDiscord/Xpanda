//var _windowWidth = window_get_width();
//var _x = 0;
//var _y = 0;
//var _size = 64;

//with (OLightPoint)
//{
//	draw_surface_stretched(cubemap_get_surface(cubemap, CUBEMAP_NEG_Y), _x, _y + _size, _size, _size);
//	_x += _size;
//	draw_surface_stretched(cubemap_get_surface(cubemap, CUBEMAP_POS_X), _x, _y + _size, _size, _size);
//	draw_surface_stretched(cubemap_get_surface(cubemap, CUBEMAP_POS_Z), _x, _y, _size, _size);
//	draw_surface_stretched(cubemap_get_surface(cubemap, CUBEMAP_NEG_Z), _x, _y + _size * 2, _size, _size);
//	_x += _size;
//	draw_surface_stretched(cubemap_get_surface(cubemap, CUBEMAP_POS_Y), _x, _y + _size, _size, _size);
//	_x += _size;
//	draw_surface_stretched(cubemap_get_surface(cubemap, CUBEMAP_NEG_X), _x, _y + _size, _size, _size);
//	_x = 0;
//	_y += _size * 3;
//}

//draw_text(0, 0, string(fps) + " (" + string(fps_real) + ")");