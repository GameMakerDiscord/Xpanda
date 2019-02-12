/// @func cubemap_create(resolution)
/// @desc Creates an empty cubemap, where each side is a separate surface.
/// @param {real} resolution Size of one cube side.
/// @return {array} An array representing the cubemap.

/// @macro {real} Index at which the +X (front) cubemap surface is stored.
#macro CUBEMAP_POS_X 0

/// @macro {real} Index at which the -X (back) cubemap surface is stored.
#macro CUBEMAP_NEG_X 1

/// @macro {real} Index at which the +Y (right) cubemap surface is stored.
#macro CUBEMAP_POS_Y 2

/// @macro {real} Index at which the -Y (left) cubemap surface is stored.
#macro CUBEMAP_NEG_Y 3

/// @macro {real} Index at which the +Z (top) cubemap surface is stored.
#macro CUBEMAP_POS_Z 4

/// @macro {real} Index at which the -Z (bottom) cubemap surface is stored.
#macro CUBEMAP_NEG_Z 5

/// @macro {real} Index at which the cubemap resolution is stored.
#macro CUBEMAP_SIZE  6

gml_pragma("forceinline");
return [
	noone,
	noone,
	noone,
	noone,
	noone,
	noone,
	argument0
];