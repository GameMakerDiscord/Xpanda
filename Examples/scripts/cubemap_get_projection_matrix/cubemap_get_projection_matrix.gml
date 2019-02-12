/// @func cubemap_get_projection_matrix(znear, zfar)
/// @desc Creates a projection matrix for the cubemap.
/// @param {real} znear Distance to the near clipping plane of the projection.
/// @param {real} zfar  Distance to the far clipping plane of the projection.
/// @return {array} The projection matrix.
gml_pragma("forceinline");
return matrix_build_projection_perspective_fov(90, 1, argument0, argument1);