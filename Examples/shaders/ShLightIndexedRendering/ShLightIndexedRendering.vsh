attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec4 v_vPosition;
varying vec4 v_vPositionWorld;
varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vPosition = gl_Position;
	v_vPositionWorld = gm_Matrices[MATRIX_WORLD] * in_Position;
	v_vNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	v_vTexCoord = in_TextureCoord;
}