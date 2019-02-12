struct VS_in
{
	float4 Position : POSITION0; // (x,y,z,w)
	float3 Normal   : NORMAL0;   // (x,y,z)
	float4 Color    : COLOR0;    // (r,g,b,a)
	float2 TexCoord : TEXCOORD0; // (u,v)
};

struct VS_out
{
	float4 Position : SV_POSITION;
	float3 Normal   : NORMAL0;
	float4 Color    : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

void main(in VS_in IN, out VS_out OUT)
{
	OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], IN.Position);
	OUT.Normal   = mul(gm_Matrices[MATRIX_WORLD], float4(IN.Normal, 0.0)).xyz;
	OUT.Color    = IN.Color;
	OUT.TexCoord = IN.TexCoord;
}