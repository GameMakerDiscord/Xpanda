/// @func mesh_to_vbuffer(mesh, format)
/// @desc Creates a vertex buffer from the mesh.
/// @param {real} mesh   The id of the mesh.
/// @param {real} format The vertex buffer format.
/// @return {real} The id of the vertex buffer on success or `noone` on fail.
var _mesh   = argument0;
var _vertex = _mesh[? "vertex"];
var _face   = _mesh[? "face"];
var _size   = ds_list_size(_face);
var i       = 0;

var _vBuffer = vertex_create_buffer();
vertex_begin(_vBuffer, argument1);

switch (argument1)
{
	case global.vBufferFormatBare:
		while (i < _size)
		{
			var f = _face[| i++];
			var v = f[? "vertex"];
			vertex_position_3d(
				_vBuffer, _vertex[| v], _vertex[| v + 1], _vertex[| v + 2]);
		}
		break;

	case global.vBufferFormat:
		var _texture   = _mesh[? "texture"];
		var _normal    = _mesh[? "normal"];
		var _tangent   = _mesh[? "tangent"];
		var _bitangent = _mesh[? "bitangent"];
		while (i < _size)
		{
			var f  = _face[| i++];
			var v  = f[? "vertex"];
			var uv = f[? "texture"];
			var n  = f[? "normal"];
			var t  = f[? "tangent"];
			var b  = f[? "bitangent"];
			vertex_position_3d(
				_vBuffer, _vertex[| v], _vertex[| v + 1], _vertex[| v + 2]);
			vertex_normal(
				_vBuffer, _normal[| n], _normal[| n + 1], _normal[| n + 2]);
			vertex_texcoord(_vBuffer, _texture[| uv], _texture[| uv + 1]);
			vertex_float4(
				_vBuffer, _tangent[| t], _tangent[| t + 1], _tangent[| t + 2], _bitangent[| b]);
		}
		break;

	default:
		show_error("Procedure not defined for given vertex format!", true);
}

vertex_end(_vBuffer);
vertex_freeze(_vBuffer);
return _vBuffer;