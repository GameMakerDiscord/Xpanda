/// @func matrix_determinant(m)
/// @desc Gets the determinant of the matrix.
/// @param {array} m The matrix.
/// @return {real} The determinant of the matrix.
function matrix_determinant(argument0) {
	gml_pragma("forceinline");
	return (argument0[ 3]*argument0[ 6]*argument0[ 9]*argument0[12] - argument0[ 2]*argument0[ 7]*argument0[ 9]*argument0[12] - argument0[ 3]*argument0[ 5]*argument0[10]*argument0[12] + argument0[ 1]*argument0[ 7]*argument0[10]*argument0[12]
		+ argument0[ 2]*argument0[ 5]*argument0[11]*argument0[12] - argument0[ 1]*argument0[ 6]*argument0[11]*argument0[12] - argument0[ 3]*argument0[ 6]*argument0[ 8]*argument0[13] + argument0[ 2]*argument0[ 7]*argument0[ 8]*argument0[13]
		+ argument0[ 3]*argument0[ 4]*argument0[10]*argument0[13] - argument0[ 0]*argument0[ 7]*argument0[10]*argument0[13] - argument0[ 2]*argument0[ 4]*argument0[11]*argument0[13] + argument0[ 0]*argument0[ 6]*argument0[11]*argument0[13]
		+ argument0[ 3]*argument0[ 5]*argument0[ 8]*argument0[14] - argument0[ 1]*argument0[ 7]*argument0[ 8]*argument0[14] - argument0[ 3]*argument0[ 4]*argument0[ 9]*argument0[14] + argument0[ 0]*argument0[ 7]*argument0[ 9]*argument0[14]
		+ argument0[ 1]*argument0[ 4]*argument0[11]*argument0[14] - argument0[ 0]*argument0[ 5]*argument0[11]*argument0[14] - argument0[ 2]*argument0[ 5]*argument0[ 8]*argument0[15] + argument0[ 1]*argument0[ 6]*argument0[ 8]*argument0[15]
		+ argument0[ 2]*argument0[ 4]*argument0[ 9]*argument0[15] - argument0[ 0]*argument0[ 6]*argument0[ 9]*argument0[15] - argument0[ 1]*argument0[ 4]*argument0[10]*argument0[15] + argument0[ 0]*argument0[ 5]*argument0[10]*argument0[15]);


}
