/// @func mesh_create()
/// @desc Creates an empty mesh.
/// @return {real} The id of the ds_map containing mesh data.
var _mesh = ds_map_create();

var _vertex = ds_list_create(); // [vX, vY, vZ, ...]
ds_map_add_list(_mesh, "vertex", _vertex);

// Three consecutive maps describe a face.
var _face = ds_list_create(); // [{vertexIndex, normalIndex, textureIndex, etc.}, ...]
ds_map_add_list(_mesh, "face", _face);

return _mesh;