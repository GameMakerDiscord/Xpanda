event_inherited();

if (keyboard_check_pressed(vk_space))
{
	instance_create_3d(OLight, x, y, z);
}
else if (keyboard_check_pressed(vk_backspace))
{
	instance_destroy(OLight);
}