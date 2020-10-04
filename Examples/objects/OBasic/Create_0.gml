/// @object A basic example.
/// @extends OExample
if (!variable_instance_exists(id, "title"))
{
	title = "Basic Example";
}

event_inherited();

x = 10;
z = 1;
direction = 180;

/// @var {Model}
model = new Model("Scene.obj").freeze();