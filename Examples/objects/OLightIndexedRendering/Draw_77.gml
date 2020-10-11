var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

var _surfaceWidth = _windowWidth * antialiasinig;
var _surfaceHeight = _windowHeight * antialiasinig;

var _tanFovY = dtan(fov * 0.5);
var _aspect = _windowWidth / _windowHeight;
var _tanAspect = [_tanFovY * _aspect, -_tanFovY];

// Depth buffer
surDepthBuffer = ce_surface_check(surDepthBuffer, _surfaceWidth, _surfaceHeight);

surface_set_target(application_surface);
draw_clear(c_red);

camera_apply(camera);

shader_set(ShDepthBuffer);
shader_set_uniform_f(shader_get_uniform(ShDepthBuffer, "u_fZFar"), zfar);
model.submit(pr_trianglelist, sprite_get_texture(SprDefault, 0));
shader_reset();

surface_reset_target();

ce_surface_copy(application_surface, surDepthBuffer);

// Light index buffer
surLightData = ce_surface_check(surLightData, 8, 256);

surLightIndexBuffer = ce_surface_check(surLightIndexBuffer, _surfaceWidth, _surfaceHeight);

surface_set_target(application_surface);
ce_surface_clear_color(0, 0);

camera_apply(camera);

gpu_push_state();
gpu_set_blendenable(true);
gpu_set_blendmode_ext(bm_one, bm_zero);
gpu_set_zwriteenable(false);
gpu_set_cullmode(cull_clockwise);
gpu_set_zfunc(cmpfunc_greaterequal);

var _modLight = modLight;
var _index = 1;

var _lightCount = instance_number(OLight);
var _lights = array_create(_lightCount);
var i = 0;

var _bboxMin = ce_vec3_create(-8192, -8192, -8192);
var _bboxMax = ce_vec3_create(+8192, +8192, +8192);

with (OLight)
{
	_lights[@ i++] = id;
	indexChannel = 0;
}

buffer_seek(bufLightData, buffer_seek_start, buffer_sizeof(buffer_u32) * 8);

function encode_float_to_surface_buffer(_f, _buffer)
{
	gml_pragma("forceinline");

	var _w = frac(_f * 16581375);
	var _z = frac(_f * 65025) - (_w / 255);
	var _y = frac(_f * 255) - (_z / 255);
	var _x = frac(_f) - (_y / 255);

	buffer_write(_buffer, buffer_u8, _x * 255);
	buffer_write(_buffer, buffer_u8, _y * 255);
	buffer_write(_buffer, buffer_u8, _z * 255);
	buffer_write(_buffer, buffer_u8, _w * 255);
}

function ce_invlerp(_a, _b, _v)
{
	gml_pragma("forceinline");
	return ((_v - _a) / (_b - _a));
}

i = 0;
repeat (_lightCount)
{
	var _l1 = _lights[i];
	_l1.index = _index++;
	
	var j = i + 1;
	repeat (_lightCount - j)
	{
		var _l2 = _lights[j++];
		if (point_distance_3d(_l1.x, _l1.y, _l1.z, _l2.x, _l2.y, _l2.z) < _l1.radius + _l2.radius)
		{
			++_l2.indexChannel;
		}
	}

	++i;

	var _xBbox = ce_invlerp(_bboxMin[0], _bboxMax[0], _l1.x);
	var _yBbox = ce_invlerp(_bboxMin[1], _bboxMax[1], _l1.y);
	var _zBbox = ce_invlerp(_bboxMin[2], _bboxMax[2], _l1.z);

	encode_float_to_surface_buffer(_xBbox, bufLightData);
	encode_float_to_surface_buffer(_yBbox, bufLightData);
	encode_float_to_surface_buffer(_zBbox, bufLightData);
	encode_float_to_surface_buffer(_l1.radius / 1000, bufLightData);
	buffer_write(bufLightData, buffer_u32, ce_color_alpha_to_argb(_l1.color, 1));
	encode_float_to_surface_buffer(_l1.intensity / 16384, bufLightData);
	buffer_seek(bufLightData, buffer_seek_relative, buffer_sizeof(buffer_u32) * 2);
}

buffer_set_surface(bufLightData, surLightData, buffer_surface_copy, 0, 0);

var _shader = ShLightIndex;
shader_set(_shader);

var _uZFar = shader_get_uniform(_shader, "u_fZFar");
var _uTanAspect = shader_get_uniform(_shader, "u_vTanAspect");
var _uViewInverse = shader_get_uniform(_shader, "u_mViewInverse");
var _uIndex = shader_get_uniform(_shader, "u_vIndex");
var _uLight = shader_get_uniform(_shader, "u_vLight");

shader_set_uniform_f(_uZFar, zfar);
shader_set_uniform_f_array(_uTanAspect, _tanAspect);
shader_set_uniform_matrix_array(_uViewInverse, matrixViewInverse);

var _depthBuffer = surface_get_texture(surDepthBuffer);

with (OLight)
{
	gpu_set_colorwriteenable(indexChannel == 0, indexChannel == 1, indexChannel == 2, indexChannel == 3);
	shader_set_uniform_f(_uIndex,
		(indexChannel == 0) ? index / 255 : 0,
		(indexChannel == 1) ? index / 255 : 0,
		(indexChannel == 2) ? index / 255 : 0,
		(indexChannel == 3) ? index / 255 : 0);
	shader_set_uniform_f(_uLight, x, y, z, radius);
	var _scale = radius * 1.5;
	matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, _scale, _scale, _scale));
	_modLight.submit(pr_trianglelist, _depthBuffer);
}
matrix_set(matrix_world, matrix_build_identity());
shader_reset();

gpu_pop_state();

surface_reset_target();

ce_surface_copy(application_surface, surLightIndexBuffer);

// Render scene
surface_set_target(application_surface);
ce_surface_clear_color(0, 1);

camera_apply(camera);

gpu_push_state();
gpu_set_zwriteenable(false);
shader_set(ShLightIndexedRendering);
texture_set_stage(shader_get_sampler_index(ShLightIndexedRendering, "u_texLightIndex"),
	surface_get_texture(surLightIndexBuffer));
texture_set_stage(shader_get_sampler_index(ShLightIndexedRendering, "u_texLightData"),
	surface_get_texture(surLightData));
gpu_set_tex_filter_ext(shader_get_sampler_index(ShLightIndexedRendering, "u_texLightData"), false);
gpu_set_tex_mip_enable_ext(shader_get_sampler_index(ShLightIndexedRendering, "u_texLightData"), false);
shader_set_uniform_f_array(shader_get_uniform(ShLightIndexedRendering, "u_vBboxMin"),
	_bboxMin);
shader_set_uniform_f_array(shader_get_uniform(ShLightIndexedRendering, "u_vBboxMax"),
	_bboxMax);
shader_set_uniform_f_array(shader_get_uniform(ShLightIndexedRendering, "u_vTanAspect"),
	_tanAspect);
model.submit(pr_trianglelist, sprite_get_texture(SprDefault, 0));
shader_reset();
gpu_pop_state();

surface_reset_target();

// Render final image to screen
draw_surface_stretched(application_surface, 0, 0, _windowWidth, _windowHeight);

//gpu_push_state();
//gpu_set_blendenable(false);
//gpu_set_tex_filter(false);
//draw_surface_ext(surLightData, 0, 0, 8, 8, 0, c_white, 1);
//gpu_pop_state();

if (keyboard_check(vk_f1))
{
	shader_set(ShLightComplexity);
	draw_surface_stretched(surLightIndexBuffer, 0, 0, _windowWidth, _windowHeight);
	shader_reset();

	var _col = surface_getpixel_ext(surLightIndexBuffer, window_mouse_get_x() * 2, window_mouse_get_y() * 2);
	var _alpha = (_col >> 24) & 255;
	var _blue = (_col >> 16) & 255;
	var _green = (_col >> 8) & 255;
	var _red = _col & 255;

	ce_draw_text_shadow(window_mouse_get_x() + 16, window_mouse_get_y() + 16,
		"red: " + string(_red)
		+ "\ngreen: " + string(_green)
		+ "\nblue: " + string(_blue)
		+ "\nalpha: " + string(_alpha));
}