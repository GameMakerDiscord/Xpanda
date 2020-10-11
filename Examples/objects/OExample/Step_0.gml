// Mouselook
var _mouseX = window_mouse_get_x();
var _mouseY = window_mouse_get_y();

if (mouse_check_button_pressed(mb_right))
{
	mouseLockAt[0] = _mouseX;
	mouseLockAt[1] = _mouseY;
}

if (mouse_check_button(mb_right))
{
	var _mouseSens = 0.75;
	direction += (mouseLockAt[0] - _mouseX) * _mouseSens;
	directionZ += (mouseLockAt[1] - _mouseY) * _mouseSens;
	directionZ = clamp(directionZ, -89, 89);
	window_mouse_set(mouseLockAt[0], mouseLockAt[1]);
	window_set_cursor(cr_none);
}
else
{
	window_set_cursor(cr_arrow);
}

// Move around
var _speed = 0.25 * (keyboard_check(vk_shift) ? 2 : 1);

if (keyboard_check(ord("W")))
{
	x += dcos(direction) * _speed;
	y -= dsin(direction) * _speed;
}
else if (keyboard_check(ord("S")))
{
	x -= dcos(direction) * _speed;
	y += dsin(direction) * _speed;
}

if (keyboard_check(ord("A")))
{
	x += dcos(direction + 90) * _speed;
	y -= dsin(direction + 90) * _speed;
}
else if (keyboard_check(ord("D")))
{
	x += dcos(direction - 90) * _speed;
	y -= dsin(direction - 90) * _speed;
}

z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;

// Build camera matrices
var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

var _matrixView = matrix_build_lookat(
	x, y, z,
	x + dcos(direction),
	y - dsin(direction),
	z + dtan(directionZ),
	0, 0, 1);

camera_set_view_mat(camera, _matrixView);

matrixViewInverse = ce_matrix_clone(_matrixView);
ce_matrix_inverse(matrixViewInverse);

camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-fov, -_windowWidth / _windowHeight, znear, zfar));

// Check application surface size
ce_surface_check(application_surface,
	_windowWidth * antialiasinig,
	_windowHeight * antialiasinig);