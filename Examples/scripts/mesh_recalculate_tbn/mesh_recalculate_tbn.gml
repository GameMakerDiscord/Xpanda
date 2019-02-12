/// @func mesh_recalculate_tbn(mesh)
/// @desc Recalculates tangent vectors and bitangent sign for the mesh.
/// @param {real} mesh The id of the mesh.
/// @return {bool} True on success.
/// @source http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-13-normal-mapping/
var _mesh      = argument0;
var _vertex    = _mesh[? "vertex"];
var _texture   = _mesh[? "texture"];
var _tangent   = _mesh[? "tangent"];
var _bitangent = _mesh[? "bitangent"];
var _normal    = _mesh[? "normal"];
var _face      = _mesh[? "face"];

// Clear tangent and bitangent data
if (is_undefined(_tangent))
{
	_tangent = ds_list_create(); // [x, y, z, ...]
	ds_map_add_list(_mesh, "tangent", _tangent);
}
else
{
	ds_list_clear(_tangent);
}

if (is_undefined(_bitangent))
{
	_bitangent = ds_list_create(); // [sign, ...]
	ds_map_add_list(_mesh, "bitangent", _bitangent);
}
else
{
	ds_list_clear(_bitangent);
}

// Calculate tangent and bitangent
var _size = ds_list_size(_face);
var i     = 0;
var _tIdx = 0;
var _bIdx = 0;
var _temp;

while (i < _size)
{
	// First vertex data
	var _f0  = _face[| i++];
	var _v0  = _f0[? "vertex"];
	var _uv0 = _f0[? "texture"];
	var _n0  = _f0[? "normal"];

	// Second vertex data
	var _f1  = _face[| i++];
	var _v1  = _f1[? "vertex"];
	var _uv1 = _f1[? "texture"];
	var _n1  = _f1[? "normal"];

	// Third vertex data
	var _f2  = _face[| i++];
	var _v2  = _f2[? "vertex"];
	var _uv2 = _f2[? "texture"];
	var _n2  = _f2[? "normal"];

	// Edges of the triangle : postion delta
	var _vecV0 = [_vertex[| _v0], _vertex[| _v0+1], _vertex[| _v0+2]];
	var _vecV1 = [_vertex[| _v1], _vertex[| _v1+1], _vertex[| _v1+2]];
	var _vecV2 = [_vertex[| _v1], _vertex[| _v2+1], _vertex[| _v2+2]];

	var _deltaPos1 = vec3_clone(_vecV1);
	vec3_subtract(_deltaPos1, _vecV0);

	var _deltaPos2 = vec3_clone(_vecV2);
	vec3_subtract(_deltaPos2, _vecV0);

	// UV delta
	var _vecUV0 = [_texture[| _uv0], _texture[| _uv0+1]];
	var _vecUV1 = [_texture[| _uv1], _texture[| _uv1+1]];
	var _vecUV2 = [_texture[| _uv2], _texture[| _uv2+1]];

	var _deltaUV1 = vec2_clone(_vecUV1);
	vec2_subtract(_deltaUV1, _vecUV0);

	var _deltaUV2 = vec2_clone(_vecUV2);
	vec2_subtract(_deltaUV2, _vecUV0);

	// Compute the tangent and the bitangent vectors
	var _r = 1 / (_deltaUV1[0]*_deltaUV2[1] - _deltaUV1[1]*_deltaUV2[0]);

	var _T = vec3_clone(_deltaPos1);
	vec3_scale(_T, _deltaUV2[1]);
	_temp = vec3_clone(_deltaPos2);
	vec3_scale(_temp, _deltaUV1[1]);
	vec3_subtract(_T, _temp);
	vec3_scale(_T, _r);

	var _B = vec3_clone(_deltaPos2);
	vec3_scale(_B, _deltaUV1[0]);
	_temp = vec3_clone(_deltaPos1);
	vec3_scale(_temp, _deltaUV2[0]);
	vec3_subtract(_B, _temp);
	vec3_scale(_B, _r);

	// Orthogonalize
	var _vecN0 = [_normal[| _n0], _normal[| _n0+1], _normal[| _n0+2]];
	var _vecN1 = [_normal[| _n1], _normal[| _n1+1], _normal[| _n1+2]];
	var _vecN2 = [_normal[| _n2], _normal[| _n2+1], _normal[| _n2+2]];

	var _T0 = vec3_clone(_T);
	_temp = vec3_clone(_vecN0);
	vec3_scale(_temp, vec3_dot(_temp, _T));
	vec3_subtract(_T0, _temp);
	vec3_normalize(_T0);

	var _T1 = vec3_clone(_T);
	_temp = vec3_clone(_vecN1);
	vec3_scale(_temp, vec3_dot(_temp, _T));
	vec3_subtract(_T1, _temp);
	vec3_normalize(_T1);

	var _T2 = vec3_clone(_T);
	_temp = vec3_clone(_vecN2);
	vec3_scale(_temp, vec3_dot(_temp, _T));
	vec3_subtract(_T2, _temp);
	vec3_normalize(_T2);

	var _B0 = vec3_clone(_B);
	_temp = vec3_clone(_vecN0);
	vec3_scale(_temp, vec3_dot(_temp, _B));
	vec3_subtract(_B0, _temp);
	vec3_normalize(_B0);
	_temp = vec3_clone(_T0);
	vec3_scale(_temp, vec3_dot(_temp, _B0));
	vec3_subtract(_B0, _temp);
	vec3_normalize(_B0);

	var _B1 = vec3_clone(_B);
	_temp = vec3_clone(_vecN1);
	vec3_scale(_temp, vec3_dot(_temp, _B));
	vec3_subtract(_B1, _temp);
	vec3_normalize(_B1);
	_temp = vec3_clone(_T1);
	vec3_scale(_temp, vec3_dot(_temp, _B1));
	vec3_subtract(_B1, _temp);
	vec3_normalize(_B1);

	var _B2 = vec3_clone(_B);
	_temp = vec3_clone(_vecN2);
	vec3_scale(_temp, vec3_dot(_temp, _B));
	vec3_subtract(_B2, _temp);
	vec3_normalize(_B2);
	_temp = vec3_clone(_T2);
	vec3_scale(_temp, vec3_dot(_temp, _B2));
	vec3_subtract(_B2, _temp);
	vec3_normalize(_B2);

	// Handedness sign for bitangent
	var _B0s = 1;
	var _B1s = 1;
	var _B2s = 1;

	_temp = vec3_clone(_vecN0);
	vec3_cross(_temp, _T0);
	if (vec3_dot(_temp, _B0) < 0)
	{
		_B0s = -1;
	}

	_temp = vec3_clone(_vecN1);
	vec3_cross(_temp, _T1);
	if (vec3_dot(_temp, _B1) < 0)
	{
		_B1s = -1;
	}

	_temp = vec3_clone(_vecN2);
	vec3_cross(_temp, _T2);
	if (vec3_dot(_temp, _B2) < 0)
	{
		 _B2s = -1;
	}

	// Save data
	ds_list_add(_tangent, _T0[0], _T0[1], _T0[2]);
	ds_list_add(_tangent, _T1[0], _T1[1], _T1[2]);
	ds_list_add(_tangent, _T2[0], _T2[1], _T2[2]);

	ds_list_add(_bitangent, _B0s);
	ds_list_add(_bitangent, _B1s);
	ds_list_add(_bitangent, _B2s);

	_f0[? "tangent"]   = _tIdx;
	_f0[? "bitangent"] = _bIdx;

	_f1[? "tangent"]   = _tIdx + 3;
	_f1[? "bitangent"] = _bIdx + 1;

	_f2[? "tangent"]   = _tIdx + 6;
	_f2[? "bitangent"] = _bIdx + 2;

	_tIdx += 9;
	_bIdx += 3;
}

return true;