/// @func mesh_load_obj(file)
/// @desc Loads a 3D mesh data into a ds_map from the *.obj file.
/// @param {string} file The path to the file.
/// @return {real} The id of the mesh on success or `noone` on fail.
function mesh_load_obj(argument0) {
	var _file = file_text_open_read(argument0);
	if (_file == -1)
	{
		return noone;
	}

	// Create mesh structure
	var _mesh       = mesh_create();
	var _vertex     = _mesh[? "vertex"];
	var _face       = _mesh[? "face"];
	var _hasNormal  = ds_map_exists(_mesh, "normal");
	var _normal     = _hasNormal ? _mesh[? "normal"] : ds_list_create();
	var _hasTexture = ds_map_exists(_mesh, "texture");
	var _texture    = _hasTexture ? _mesh[? "texture"] : ds_list_create();

	// Laod mesh data
	while (!file_text_eof(_file))
	{
		var _line = file_text_read_string(_file);
		var _split = string_explode(_line, " ");

		switch (_split[0])
		{
			// Vertex
			case "v":
				ds_list_add(_vertex, real(_split[1]));
				ds_list_add(_vertex, real(_split[2]));
				ds_list_add(_vertex, real(_split[3]));
				break;

			// Vertex normal
			case "vn":
				ds_list_add(_normal, real(_split[1]));
				ds_list_add(_normal, real(_split[2]));
				ds_list_add(_normal, real(_split[3]));
				break;

			// Vertex texture coordinate
			case "vt":
				ds_list_add(_texture, real(_split[1]));
				ds_list_add(_texture, real(_split[2]));
				break;

			// Face
			case "f":
				for (var i = 1; i < 4; ++i)
				{
					var _f = string_explode(_split[i], "/");
					var _faceMap = ds_map_create();

					_faceMap[? "vertex"] = (real(_f[0]) - 1) * 3;
					if (array_length_1d(_f) == 3)
					{
						if (_f[1] != "")
						{
							_faceMap[? "texture"] = (real(_f[1]) - 1) * 2;
						}
						_faceMap[? "normal"] = (real(_f[2]) - 1) * 3;
					}

					ds_list_add(_face, _faceMap);
					ds_list_mark_as_map(_face, ds_list_size(_face) - 1);
				}
				break;
		}

		file_text_readln(_file);
	}
	file_text_close(_file);

	if (!_hasNormal)
	{
		if (ds_list_empty(_normal))
		{
			ds_list_destroy(_normal);
		}
		else
		{
			ds_map_add_list(_mesh, "normal", _normal);
		}
	}

	if (!_hasTexture)
	{
		if (ds_list_empty(_texture))
		{
			ds_list_destroy(_texture);
		}
		else
		{
			ds_map_add_list(_mesh, "texture", _texture);
		}
	}

	return _mesh;


}
