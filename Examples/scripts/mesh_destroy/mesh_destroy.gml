/// @func mesh_destroy(mesh)
/// @desc Destroys the mesh.
/// @param {real} mesh The id of the mesh.
function mesh_destroy(argument0) {
	gml_pragma("forceinline");
	ds_map_destroy(argument0);


}
