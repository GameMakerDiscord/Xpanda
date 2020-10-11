/// @object An example of light indexed rendering.
/// @extends OBasic
if (!variable_instance_exists(id, "title"))
{
	title = "Light Indexed Rendering";
}

info = "Hold F1 to visualize lighting complexity.";

event_inherited();

surGBuffer = noone;

bufLightData = buffer_create(256 * 8 * buffer_sizeof(buffer_u32), buffer_fixed, 1);
surLightData = noone;
surLightIndexBuffer = noone;

modLight = new Model("IcoSphere.obj").freeze();