/// @func vec3_clone(v)
/// @desc Creates a clone of the vector.
/// @param {array} v The vector.
/// @return {array} The created clone.
gml_pragma("forceinline");
return [argument0[0], argument0[1], argument0[2]];