struct VS_out
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
};

struct PS_out
{
	float4 Target0 : SV_TARGET0;
};

Texture2D texAmbientOcclusion : register(t1);
Texture2D texEmissive         : register(t2);

uniform float4 u_vAmbient; // (r,g,b,intensity)

void main(in VS_out IN, out PS_out OUT)
{
	float4 base = gm_BaseTextureObject.Sample(gm_BaseTexture, IN.TexCoord);
	if (base.a < 1.0)
	{
		discard;
	}
	float4 ambient = float4(u_vAmbient.rgb * u_vAmbient.a, 1.0)
		* texAmbientOcclusion.Sample(gm_BaseTexture, IN.TexCoord);
	float4 emissive = texEmissive.Sample(gm_BaseTexture, IN.TexCoord);
	OUT.Target0 = base * (ambient + emissive);
	OUT.Target0.a = 1.0;
}