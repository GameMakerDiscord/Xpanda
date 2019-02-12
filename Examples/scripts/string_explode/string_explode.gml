/// @func string_explode(string, char)
/// @desc Splits given string on every `char` and puts created parts into an
///       array.
/// @param {string} string The string to explode.
/// @param {string} char   The character to split the string on.
/// @return {array} The created array.
var a = [];
var i = 0;
var s;
do
{
	s = string_split_on_first(argument0, argument1);
	a[i++] = s[0]; 
	argument0 = s[1];
}
until (s[1] == "");
return a;