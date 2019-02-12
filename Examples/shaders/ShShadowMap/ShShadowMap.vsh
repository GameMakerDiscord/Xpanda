#define in_TangentW in_TextureCoord1

attribute vec4 in_Position;      // (x,y,z,w)
attribute vec3 in_Normal;        // (x,y,z)
attribute vec2 in_TextureCoord0; // (u,v)
attribute vec4 in_TangentW;      // (tangent.xyz,bitangentSign)

varying vec2 v_vTexCoord;
varying vec3 v_vPosWorld;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vTexCoord = in_TextureCoord0;
	v_vPosWorld = (gm_Matrices[MATRIX_WORLD] * in_Position).xyz;
}