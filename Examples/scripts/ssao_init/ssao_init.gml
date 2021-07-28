/// @func ssao_init(radius, bias, power)
/// @desc Initializes resources necessary for the SSAO funcionality.
/// @param {real} radius Radius of the occlusion effect. Anything further than
///                      that won't add to occlusion.
/// @param {real} bias   Depth bias to avoid too much self occlusion. Higher
///                      values mean lower self occlusion.
/// @param {real} power  Strength of the occlusion effect. Should be greater
///                      than 0.
function ssao_init(argument0, argument1, argument2) {

	//> Comment out if you are using view-space normals instead of world-space.
	//> This line is also present in the ShSSAO shader, so don't forget to comment
	//> out that one as well!
#macro SSAO_WORLD_SPACE_NORMALS true

	//> Size of the noise texture. Must be the same value as in the ShSSAOBlur
	//> shader!
#macro SSAO_NOISE_TEXTURE_SIZE 4

	//> The higher the better quality, but lower performance. Values between 16 and
	//> 64 are suggested. Must be the same values as in the ShSSAO shader!
#macro SSAO_KERNEL_SIZE 16

	surSsaoNoise = noone;
	ssaoKernel   = ssao_create_kernel(SSAO_KERNEL_SIZE);
	ssaoRadius   = argument0;
	ssaoBias     = argument1;
	ssaoPower    = argument2;

	// Uniforms
	uSsaoTexNormal    = shader_get_sampler_index(ShSSAO, "texNormal");
	uSsaoTexRandom    = shader_get_sampler_index(ShSSAO, "texRandom");
	uSsaoMatView      = shader_get_uniform(ShSSAO, "u_mView");
	uSsaoMatProj      = shader_get_uniform(ShSSAO, "u_mProjection");
	uSsaoTexel        = shader_get_uniform(ShSSAO, "u_vTexel");
	uSsaoClipFar      = shader_get_uniform(ShSSAO, "u_fClipFar");
	uSsaoTanAspect    = shader_get_uniform(ShSSAO, "u_vTanAspect");
	uSsaoSampleKernel = shader_get_uniform(ShSSAO, "u_vSampleKernel");
	uSsaoRadius       = shader_get_uniform(ShSSAO, "u_fRadius");
	uSsaoPower        = shader_get_uniform(ShSSAO, "u_fPower");
	uSsaoNoiseScale   = shader_get_uniform(ShSSAO, "u_vNoiseScale");
	uSsaoBias         = shader_get_uniform(ShSSAO, "u_fBias");
	uSsaoBlurTexel    = shader_get_uniform(ShSSAOBlur, "u_vTexel");


}
