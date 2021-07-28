/// @func vec3_create(x[, y, z])
/// @desc Creates a new vector with given components. If only the first value
///       is supplied, then it is used for every component.
/// @param {real} x The first vector component.
/// @param {real} y The second vector component.
/// @param {real} z The third vector component.
/// @return {array} The created vector.
/// @note One could also just write `[x, y, z]`, which would give the same
///       result.
function vec3_create() {
	gml_pragma("forceinline");
	if (argument_count == 1)
	{
		return [argument[0], argument[0], argument[0]];
	}
	return [argument[0], argument[1], argument[2]];


}
