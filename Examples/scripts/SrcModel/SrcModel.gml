vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
global.vertexFormat = vertex_format_end();

/// @func Model([_path])
/// @param {string} [_path] Path to an *.obj file.
function Model() constructor
{
	/// @var {vertex_buffer/undefined} A vertex buffer or `undefined` if the model
	/// hasn't been loaded yet.
	/// @readonly
	Buffer = undefined;

	/// @func SaveBuffer(_path)
	/// @desc Saves the model into a binary file.
	/// @param {string} _path The path to the file.
	/// @return {Model} Returns `self`.
	static SaveBuffer = function (_path)
	{
		var _buffer = buffer_create_from_vertex_buffer(Buffer, buffer_fixed, 1);
		buffer_save(_buffer, _path);
		buffer_delete(_buffer);
		return self;
	};

	/// @func LoadBuffer(_path)
	/// @desc Loads a model from a binary file.
	/// @param {string} _path Path to the file.
	/// @return {Model} Returns `self`.
	/// @see Model.SaveBuffer
	static LoadBuffer = function (_path)
	{
		var _buffer = buffer_load(_path);
		Buffer = vertex_create_buffer_from_buffer(_buffer, global.vertexFormat);
		buffer_delete(_buffer);
		return self;
	};

	/// @func LoadObj(_path)
	/// @desc Loads a model from an *.obj file.
	/// @param {string} _path Path to the *.obj file.
	/// @return {Model} Returns `self`.
	static LoadObj = function (_path)
	{
		Destroy();

		Buffer = vertex_create_buffer();
		vertex_begin(Buffer, global.vertexFormat);

		var _vertices = ds_list_create();
		var _normals = ds_list_create();
		var _textures = ds_list_create();

		var _file = file_text_open_read(_path);
		while (!file_text_eof(_file))
		{
			var _line = file_text_read_string(_file);
			file_text_readln(_file);
			var _exploded = ExplodeString(_line, " ");

			switch (_exploded[0])
			{
			case "v":
				ds_list_add(_vertices, real(_exploded[1]), real(-_exploded[2]), real(_exploded[3]));
				break;

			case "vn":
				ds_list_add(_normals, real(_exploded[1]), real(-_exploded[2]), real(_exploded[3]));
				break;

			case "vt":
				ds_list_add(_textures, real(_exploded[1]), 1.0 - real(_exploded[2]));
				break;

			case "f":
				var i = 1;
				var _index = 8;
				var _indices = array_create(9, 0);
				repeat (3)
				{
					var _face = ExplodeString(_exploded[i++], "/");
					var _v = (real(_face[0]) - 1) * 3;
					var _t = (real(_face[1]) - 1) * 2;
					var _n = (real(_face[2]) - 1) * 3;
					_indices[_index--] = _t;
					_indices[_index--] = _n;
					_indices[_index--] = _v;
				}
				_index = 0;
				repeat (3)
				{
					var _v = _indices[_index++];
					var _n = _indices[_index++];
					var _t = _indices[_index++];
					vertex_position_3d(Buffer, _vertices[| _v], _vertices[| _v + 1], _vertices[| _v + 2]);
					vertex_normal(Buffer, _normals[| _n], _normals[| _n + 1], _normals[| _n + 2]);
					vertex_texcoord(Buffer, _textures[| _t], _textures[| _t + 1]);
				}
				break;
			}
		}
		file_text_close(_file);

		ds_list_destroy(_vertices);
		ds_list_destroy(_normals);
		ds_list_destroy(_textures);

		vertex_end(Buffer);

		return self;
	};

	/// @func Freeze()
	/// @desc Freezes model's vertex buffer.
	/// @return {Model} Returns `self`.
	static Freeze = function ()
	{
		vertex_freeze(Buffer);
		return self;
	};

	/// @func Submit(_prim, _texture)
	/// @desc Submits the model for rendering.
	/// @param {uint} _prim One of the `pr_` constants.
	/// @param {uint} _texture A texture.
	static Submit = function (_prim, _texture)
	{
		vertex_submit(Buffer, _prim, _texture);
	};

	/// @func Destroy()
	/// @desc Frees memory used by the model.
	static Destroy = function ()
	{
		if (Buffer != undefined)
		{
			vertex_delete_buffer(Buffer);
			Buffer = undefined;
		}
	};

	if (argument_count > 0)
	{
		var _path = argument[0];
		LoadObj(_path);
	}
}