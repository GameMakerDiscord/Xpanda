/// @object An example of light indexed rendering.
/// @extends OBasic
if (!variable_instance_exists(id, "title"))
{
	title = "Light Indexed Rendering";
}

event_inherited();

surDepthBuffer = noone;
surLightIndexBuffer = noone;

modLight = new Model("IcoSphere.obj").freeze();