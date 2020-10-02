surface_set_target(application_surface);
camera_apply(camera);
shader_set(ShBasic);
model.Submit(pr_trianglelist, sprite_get_texture(SprDefault, 0));
shader_reset();
surface_reset_target();

// Draw application surface on the screen
event_inherited();