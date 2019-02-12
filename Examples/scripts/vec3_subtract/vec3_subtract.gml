/// @func vec3_subtract(v1, v2)
/// @desc Subtracts vector `v2` from `v1` and stores the result into `v1`.
/// @param {array} v1 The vector to subtract from.
/// @param {array} v2 The vector to subtract.
argument0[@ 0] -= argument1[0];
argument0[@ 1] -= argument1[1];
argument0[@ 2] -= argument1[2];