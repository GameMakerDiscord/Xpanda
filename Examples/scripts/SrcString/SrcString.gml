/// @func ExplodeString(_string, _char)
/// @param {string} _string
/// @param {string} _char
/// @return {string[]}
function ExplodeString(_string, _char)
{
	var _occCount = string_count(_char, _string);
	var _arr = array_create(_occCount + 1, undefined);
	var _start = 1;
	var i = 0;
	repeat (_occCount)
	{
		var _end = string_pos_ext(_char, _string, _start);
		_arr[@ i++] = string_copy(_string, _start, _end - _start);
		_start = _end + 1;
	}
	_arr[@ i] = string_delete(_string, 1, _start - 1);
	return _arr;
}