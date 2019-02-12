uniform float u_fClipFar;

struct VS_in
{
	float4 Position : POSITION0; // (x,y,z,w)
	float3 Normal   : NORMAL0;   // (x,y,z)
	float2 TexCoord : TEXCOORD0; // (u,v)
	float4 TangentW : TEXCOORD1; // (tangent.xyz,bitangentSign)
};

struct VS_out
{
	float4 Position  : SV_POSITION;
	float3 Normal    : NORMAL0;
	float3 Tangent   : TANGENT0;
	float3 Bitangent : BINORMAL0;
	float2 TexCoord  : TEXCOORD0;
	float  Depth     : TEXCOORD1;
};

void main(in VS_in IN, out VS_out OUT)
{
	OUT.Position  = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], IN.Position);
	OUT.Normal    = normalize(mul(gm_Matrices[MATRIX_WORLD], float4(IN.Normal, 0.0)).xyz);
	OUT.Tangent   = normalize(mul(gm_Matrices[MATRIX_WORLD], float4(IN.TangentW.xyz, 0.0)).xyz);
	OUT.Bitangent = normalize(mul(gm_Matrices[MATRIX_WORLD],
		normalize(float4(cross(IN.Normal, IN.TangentW.xyz) * IN.TangentW.w, 0.0))).xyz);
	OUT.TexCoord  = IN.TexCoord;
	OUT.Depth     = OUT.Position.z / u_fClipFar;
}