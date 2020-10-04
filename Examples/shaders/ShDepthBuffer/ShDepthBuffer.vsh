attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexCoord;
varying float v_fDepth;

uniform float u_fZFar;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vTexCoord = in_TextureCoord;
	v_fDepth = gl_Position.z / u_fZFar;
}