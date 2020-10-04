attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec4 v_vPosition;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vPosition = gl_Position;
}