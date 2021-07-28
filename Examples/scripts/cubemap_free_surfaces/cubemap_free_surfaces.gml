/// @func cubemap_free_surfaces(cubemap)
/// @desc Frees surfaces used by the cubemap from memory.
/// @param {array} cubemap The cubemap.
function cubemap_free_surfaces(argument0) {
	var _sur;
	for (var i = 0; i < 6; ++i)
	{
		_sur = argument0[i];
		if (surface_exists(_sur))
		{
			surface_free(_sur);
		}
		argument0[@ i] = noone;
	}


}
