var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

var _tanFovY = dtan(fov * 0.5);
var _aspect = _windowWidth / _windowHeight;
var _tanAspect = [_tanFovY * _aspect, -_tanFovY];

// Depth buffer
surDepthBuffer = ce_surface_check(surDepthBuffer, _windowWidth, _windowHeight);

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
surLightIndexBuffer = ce_surface_check(surLightIndexBuffer, _windowWidth, _windowHeight);

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

with (OLight)
{
	index = _index++;
	indexChannel = 0;
	var _channel = 0;
	var _x = x;
	var _y = y;
	var _z = z;
	var _radius = radius;
	var _id = id;
	with (OLight)
	{
		if (id == _id)
		{
			continue;
		}
		if (point_distance_3d(x, y, z, _x, _y, _z) < radius + _radius)
		{
			indexChannel = ++_channel % 4;
		}
	}
}

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
shader_set(ShDefault);
model.submit(pr_trianglelist, sprite_get_texture(SprDefault, 0));
shader_reset();
gpu_pop_state();

surface_reset_target();

// Render final image to screen
draw_surface(application_surface, 0, 0);

shader_set(ShLightComplexity);
draw_surface(surLightIndexBuffer, 0, 0);
shader_reset();

var _col = surface_getpixel_ext(surLightIndexBuffer, window_mouse_get_x(), window_mouse_get_y());
var _alpha = (_col >> 24) & 255;
var _blue = (_col >> 16) & 255;
var _green = (_col >> 8) & 255;
var _red = _col & 255;

draw_text_shadow(window_mouse_get_x() + 16, window_mouse_get_y() + 16,
	"red: " + string(_red)
	+ "\ngreen: " + string(_green)
	+ "\nblue: " + string(_blue)
	+ "\nalpha: " + string(_alpha));