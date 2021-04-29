event_inherited();

cubemap_free_surfaces(cubemap);
if (surface_exists(shadowmap))
{
	surface_free(shadowmap);
}