/// @object Parent object for all examples.
/// @extends OObject3D
event_inherited();

if (variable_instance_exists(id, "title"))
{
	window_set_caption(title);
}

if (!variable_instance_exists(id, "info"))
{
	info = "";
}

application_surface_enable(true);
application_surface_draw_enable(false);

gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_cullmode(cull_counterclockwise);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);

directionZ = 0;

fov = 60;

znear = 0.1;

zfar = 8192;

camera = camera_create();

matrixViewInverse = undefined;

mouseLockAt = ce_vec2_create(0);