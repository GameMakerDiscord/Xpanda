struct VS_in
{
	float4 Position : POSITION0; // (x,y,z,w)
	float2 TexCoord : TEXCOORD0; // (u,v)
};

struct VS_out
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
};

void main(in VS_in IN, out VS_out OUT)
{
	OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], IN.Position);
	OUT.TexCoord = IN.TexCoord;
}