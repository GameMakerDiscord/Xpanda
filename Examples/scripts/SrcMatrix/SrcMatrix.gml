/// @func GetMatrixDeterminant(_matrix)
/// @desc Gets a determinant of a matrix.
/// @param {matrix} _matrix The matrix.
/// @return {real} The matrix determinant.
function GetMatrixDeterminant(_matrix)
{
	gml_pragma("forceinline");
	var _m00 = _matrix[0];
	var _m01 = _matrix[1];
	var _m02 = _matrix[2];
	var _m03 = _matrix[3];
	var _m04 = _matrix[4];
	var _m05 = _matrix[5];
	var _m06 = _matrix[6];
	var _m07 = _matrix[7];
	var _m08 = _matrix[8];
	var _m09 = _matrix[9];
	var _m10 = _matrix[10];
	var _m11 = _matrix[11];
	var _m12 = _matrix[12];
	var _m13 = _matrix[13];
	var _m14 = _matrix[14];
	var _m15 = _matrix[15];
	return (0
		+ (_m03 * _m06 * _m09 * _m12) - (_m02 * _m07 * _m09 * _m12) - (_m03 * _m05 * _m10 * _m12) + (_m01 * _m07 * _m10 * _m12)
		+ (_m02 * _m05 * _m11 * _m12) - (_m01 * _m06 * _m11 * _m12) - (_m03 * _m06 * _m08 * _m13) + (_m02 * _m07 * _m08 * _m13)
		+ (_m03 * _m04 * _m10 * _m13) - (_m00 * _m07 * _m10 * _m13) - (_m02 * _m04 * _m11 * _m13) + (_m00 * _m06 * _m11 * _m13)
		+ (_m03 * _m05 * _m08 * _m14) - (_m01 * _m07 * _m08 * _m14) - (_m03 * _m04 * _m09 * _m14) + (_m00 * _m07 * _m09 * _m14)
		+ (_m01 * _m04 * _m11 * _m14) - (_m00 * _m05 * _m11 * _m14) - (_m02 * _m05 * _m08 * _m15) + (_m01 * _m06 * _m08 * _m15)
		+ (_m02 * _m04 * _m09 * _m15) - (_m00 * _m06 * _m09 * _m15) - (_m01 * _m04 * _m10 * _m15) + (_m00 * _m05 * _m10 * _m15));
}

/// @func GetInverseMatrix(_matrix)
/// @desc Gets an inverse matrix of a matrix.
/// @param {array} _matrix The matrix.
/// @return {matrix} The inverse matrix.
function GetInverseMatrix(_matrix)
{
	var _s = 1 / GetMatrixDeterminant(_matrix);
	var _m00 = _matrix[0];
	var _m01 = _matrix[1];
	var _m02 = _matrix[2];
	var _m03 = _matrix[3];
	var _m04 = _matrix[4];
	var _m05 = _matrix[5];
	var _m06 = _matrix[6];
	var _m07 = _matrix[7];
	var _m08 = _matrix[8];
	var _m09 = _matrix[9];
	var _m10 = _matrix[10];
	var _m11 = _matrix[11];
	var _m12 = _matrix[12];
	var _m13 = _matrix[13];
	var _m14 = _matrix[14];
	var _m15 = _matrix[15];
	return [
		_s * ((_m06 * _m11 * _m13) - (_m07 * _m10 * _m13) + (_m07 * _m09 * _m14) - (_m05 * _m11 * _m14) - (_m06 * _m09 * _m15) + (_m05 * _m10 * _m15)),
		_s * ((_m03 * _m10 * _m13) - (_m02 * _m11 * _m13) - (_m03 * _m09 * _m14) + (_m01 * _m11 * _m14) + (_m02 * _m09 * _m15) - (_m01 * _m10 * _m15)),
		_s * ((_m02 * _m07 * _m13) - (_m03 * _m06 * _m13) + (_m03 * _m05 * _m14) - (_m01 * _m07 * _m14) - (_m02 * _m05 * _m15) + (_m01 * _m06 * _m15)),
		_s * ((_m03 * _m06 * _m09) - (_m02 * _m07 * _m09) - (_m03 * _m05 * _m10) + (_m01 * _m07 * _m10) + (_m02 * _m05 * _m11) - (_m01 * _m06 * _m11)),
		_s * ((_m07 * _m10 * _m12) - (_m06 * _m11 * _m12) - (_m07 * _m08 * _m14) + (_m04 * _m11 * _m14) + (_m06 * _m08 * _m15) - (_m04 * _m10 * _m15)),
		_s * ((_m02 * _m11 * _m12) - (_m03 * _m10 * _m12) + (_m03 * _m08 * _m14) - (_m00 * _m11 * _m14) - (_m02 * _m08 * _m15) + (_m00 * _m10 * _m15)),
		_s * ((_m03 * _m06 * _m12) - (_m02 * _m07 * _m12) - (_m03 * _m04 * _m14) + (_m00 * _m07 * _m14) + (_m02 * _m04 * _m15) - (_m00 * _m06 * _m15)),
		_s * ((_m02 * _m07 * _m08) - (_m03 * _m06 * _m08) + (_m03 * _m04 * _m10) - (_m00 * _m07 * _m10) - (_m02 * _m04 * _m11) + (_m00 * _m06 * _m11)),
		_s * ((_m05 * _m11 * _m12) - (_m07 * _m09 * _m12) + (_m07 * _m08 * _m13) - (_m04 * _m11 * _m13) - (_m05 * _m08 * _m15) + (_m04 * _m09 * _m15)),
		_s * ((_m03 * _m09 * _m12) - (_m01 * _m11 * _m12) - (_m03 * _m08 * _m13) + (_m00 * _m11 * _m13) + (_m01 * _m08 * _m15) - (_m00 * _m09 * _m15)),
		_s * ((_m01 * _m07 * _m12) - (_m03 * _m05 * _m12) + (_m03 * _m04 * _m13) - (_m00 * _m07 * _m13) - (_m01 * _m04 * _m15) + (_m00 * _m05 * _m15)),
		_s * ((_m03 * _m05 * _m08) - (_m01 * _m07 * _m08) - (_m03 * _m04 * _m09) + (_m00 * _m07 * _m09) + (_m01 * _m04 * _m11) - (_m00 * _m05 * _m11)),
		_s * ((_m06 * _m09 * _m12) - (_m05 * _m10 * _m12) - (_m06 * _m08 * _m13) + (_m04 * _m10 * _m13) + (_m05 * _m08 * _m14) - (_m04 * _m09 * _m14)),
		_s * ((_m01 * _m10 * _m12) - (_m02 * _m09 * _m12) + (_m02 * _m08 * _m13) - (_m00 * _m10 * _m13) - (_m01 * _m08 * _m14) + (_m00 * _m09 * _m14)),
		_s * ((_m02 * _m05 * _m12) - (_m01 * _m06 * _m12) - (_m02 * _m04 * _m13) + (_m00 * _m06 * _m13) + (_m01 * _m04 * _m14) - (_m00 * _m05 * _m14)),
		_s * ((_m01 * _m06 * _m08) - (_m02 * _m05 * _m08) + (_m02 * _m04 * _m09) - (_m00 * _m06 * _m09) - (_m01 * _m04 * _m10) + (_m00 * _m05 * _m10))
	];
}