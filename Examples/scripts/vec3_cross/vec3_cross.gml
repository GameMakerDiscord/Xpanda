/// @func vec3_cross(v1, v2)
/// @desc Gets the cross product of the vectors `v1`, `v2` and stores it to
///       `v1`.
/// @param {array} v1 The first vector.
/// @param {array} v2 The second vector.
function vec3_cross(argument0, argument1) {
	var _x = argument0[1]*argument1[2] - argument0[2]*argument1[1];
	var _y = argument0[2]*argument1[0] - argument0[0]*argument1[2];
	var _z = argument0[0]*argument1[1] - argument0[1]*argument1[0];
	argument0[@ 0] = _x;
	argument0[@ 1] = _y;
	argument0[@ 2] = _z;


}
