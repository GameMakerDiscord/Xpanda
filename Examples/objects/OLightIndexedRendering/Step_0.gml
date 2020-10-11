event_inherited();

if (keyboard_check_pressed(vk_space))
{
	ce_instance_create_3d(round(x), round(y), round(z), OLight);
}
else if (keyboard_check_pressed(vk_backspace))
{
	instance_destroy(OLight);
}