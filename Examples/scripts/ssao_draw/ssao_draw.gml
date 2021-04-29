/// @func ssao_draw(surSsao, surWork, surDepth, surNormal, matView, matProj, clipFar)
/// @desc Renders SSAO into the `surSsao` surface.
/// @param {real}  surSsao   The surface to draw the SSAO to.
/// @param {real}  surWork   A working surface used for blurring the SSAO. Must
///                          have the same size as `surSsao`!
/// @param {real}  surDepth  A surface containing the scene depth.
/// @param {real}  surNormal A surface containing the scene normals.
/// @param {array} matView   The view matrix used when rendering the scene.
/// @param {array} matProj   The projection matrix used when rendering the scene.
/// @param {real}  clipFar   A distance to the far clipping plane (same as in the
///                          projection used when rendering the scene).
function ssao_draw(argument0, argument1, argument2, argument3, argument4, argument5, argument6) {
	var _surSsao        = argument0;
	var _surWork        = argument1;
	var _surSceneDepth  = argument2;
	var _texSceneNormal = surface_get_texture(argument3);
	var _matView        = argument4;
	var _matProj        = argument5;
	var _clipFar        = argument6;
	var _tanAspect      = [1/_matProj[0], -1/_matProj[5]];
	var _width          = surface_get_width(_surSsao);
	var _height         = surface_get_height(_surSsao);

	if (!surface_exists(surSsaoNoise))
	{
		surSsaoNoise = ssao_make_noise_surface(SSAO_NOISE_TEXTURE_SIZE);
	}

	// TODO: For the SSAO, texture repeat should be enabled only for the noise
	// texture, otherwise false occlusion occurs on the screen edges.
	var _texRepeat = gpu_get_tex_repeat();
	gpu_set_tex_repeat(false);

	surface_set_target(_surSsao);
	draw_clear(0);
	shader_set(ShSSAO);
	texture_set_stage(uSsaoTexNormal, _texSceneNormal);
	texture_set_stage(uSsaoTexRandom, surface_get_texture(surSsaoNoise));
	gpu_set_texrepeat_ext(uSsaoTexRandom, true);

	if (SSAO_WORLD_SPACE_NORMALS)
	{
		shader_set_uniform_matrix_array(uSsaoMatView, _matView);
	}
	shader_set_uniform_matrix_array(uSsaoMatProj, _matProj);
	shader_set_uniform_f(uSsaoTexel, 1/_width, 1/_height);
	shader_set_uniform_f(uSsaoClipFar, _clipFar); 
	shader_set_uniform_f_array(uSsaoTanAspect, _tanAspect);
	shader_set_uniform_f_array(uSsaoSampleKernel, ssaoKernel);
	shader_set_uniform_f(uSsaoRadius, ssaoRadius);
	shader_set_uniform_f(uSsaoPower, ssaoPower);
	shader_set_uniform_f(uSsaoNoiseScale, _width/SSAO_NOISE_TEXTURE_SIZE, _height/SSAO_NOISE_TEXTURE_SIZE);
	shader_set_uniform_f(uSsaoBias, ssaoBias);
	draw_surface_stretched(_surSceneDepth, 0, 0, _width, _height);
	shader_reset();
	surface_reset_target();

	surface_set_target(_surWork);
	draw_clear(0);
	shader_set(ShSSAOBlur);
	shader_set_uniform_f(uSsaoBlurTexel, 1/_width, 0);
	draw_surface(_surSsao, 0, 0);
	shader_reset();
	surface_reset_target();

	surface_set_target(_surSsao);
	draw_clear(0);
	shader_set(ShSSAOBlur);
	shader_set_uniform_f(uSsaoBlurTexel, 0, 1/_height);
	draw_surface(_surWork, 0, 0);
	shader_reset();
	surface_reset_target();

	gpu_set_tex_repeat(_texRepeat);


}
