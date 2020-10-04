/// @func instance_create_3d(_object, _x, _y, _z)
/// @param {object} _object
/// @param {real} _x
/// @param {real} _y
/// @param {real} _z
/// @return {real}
function instance_create_3d(_object, _x, _y, _z)
{
	with (instance_create_layer(_x, _y, layer, _object))
	{
		z = _z;
		return id;
	}
}