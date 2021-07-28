/// @func ssao_free()
/// @desc Frees resources used by the SSAO from memory.
function ssao_free() {
	if (surface_exists(surSsaoNoise))
	{
		surface_free(surSsaoNoise);
	}
	ssaoKernel = noone;


}
