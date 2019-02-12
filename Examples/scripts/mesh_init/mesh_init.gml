/// @func mesh_init()
/// @desc Initializes mesh functionality.
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord); // TangentW
global.vBufferFormat = vertex_format_end();

vertex_format_begin();
vertex_format_add_position_3d();
global.vBufferFormatBare = vertex_format_end();