/// @func string_split_on_first(string, delimiter)
/// @desc Splits the string in two at the first occurence of the delimiter.
/// @param {string} string    The string to split.
/// @param {string} delimiter The delimiter.
/// @return {array} An array containing [firstHalf, secondHalf]. If the
///                 delimiter is not found in the string, then secondHalf
///                 equals empty string and firstHalf is the original string.
function string_split_on_first(argument0, argument1) {
	var i = string_pos(argument1, argument0);
	if (i == 0)
	{
		return [argument0, ""];
	}
	return [
		string_copy(argument0, 1, i - 1),
		string_delete(argument0, 1, i)
	];


}
