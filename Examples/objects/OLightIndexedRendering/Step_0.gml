event_inherited();

if (keyboard_check_pressed(vk_space))
{
	ce_instance_create_3d(x, y, z, OLight);
}
else if (keyboard_check_pressed(vk_backspace))
{
	instance_destroy(OLight);
}