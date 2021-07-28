struct VS_in
{
	float4 Position : POSITION0; // (x,y,z,w)
};

struct VS_out
{
	float4 Position : SV_POSITION;
	float4 Vertex   : TEXCOORD0;
};

void main(in VS_in IN, out VS_out OUT)
{
	OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], IN.Position);
	OUT.Vertex = OUT.Position;
}