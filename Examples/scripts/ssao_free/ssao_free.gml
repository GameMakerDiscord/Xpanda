/// @func ssao_free()
/// @desc Frees resources used by the SSAO from memory.
if (surface_exists(surSsaoNoise))
{
	surface_free(surSsaoNoise);
}
ssaoKernel = noone;