/// @func CloneArray(_array)
/// @desc Creates a clone of an array.
/// @param {array} _array The array to create a clone of.
/// @return {array} The created array.
function CloneArray(_array)
{
	gml_pragma("forceinline");
	var _length = array_length(_array);
	var _clone = array_create(_length, undefined);
	array_copy(_clone, 0, _array, 0, 16);
	return _clone;
}