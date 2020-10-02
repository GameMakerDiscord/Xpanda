/// @enum Enumeration of cube sides, compatible with Xpanda's cubemap layout.
enum ECubeSide
{
	/// @member Front cube side.
	PosX,
	/// @member Back cube side.
	NegX,
	/// @member Right cube side.
	PosY,
	/// @member Left cube side.
	NegY,
	/// @member Top cube side.
	PosZ,
	/// @member Bottom cube side.
	NegZ,
	/// @member Number of cube sides.
	SIZE
};

/// @func Cubemap(_resolution)
/// @desc A cubemap.
/// @param {uint} _resolution A resolution of single cubemap side. Must be power
/// of two.
function Cubemap(_resolution) constructor
{
	/// @var {Vec3} The position of the cubemap in the world space.
	/// @see Cubemap.GetViewMatrix
	Position = new Vec3();

	/// @var {real} Distance to the near clipping plane used in the cubemap's
	/// projection matrix. Defaults to `0.1`.
	/// @see Cubemap.GetProjectionMatrix
	ZNear = 0.1;

	/// @var {real} Distance to the far clipping plane used in the cubemap's
	/// projection matrix. Defaults to `8192`.
	/// @see Cubemap.GetProjectionMatrix
	ZFar = 8192;

	/// @var {array<surface>} An array of surfaces.
	/// @readonly
	Sides = array_create(ECubeSide.SIZE, noone);

	/// @var {surface} A single surface containing all cubemap sides.
	/// This can be passed as uniform to a shader for cubemapping.
	/// @readonly
	Surface = noone;

	/// @var {uint} A resolution of single cubemap side. Must be power of two.
	/// @readonly
	Resolution = _resolution;

	/// @var {ECubeSide} An index of a side that we are currently rendering to.
	/// @see Cubemap.SetTarget
	/// @private
	RenderTo = 0;

	/// @func GetSurface(_side)
	/// @desc Gets a surface for given cubemap side. If the surface is corrupted,
	/// then a new one is created.
	/// @param {ECubeSide} _side The cubemap side.
	/// @return {real} The surface.
	static GetSurface = function (_side)
	{
		var _surOld = Sides[_side];
		var _sur = CheckSurface(_surOld, Resolution, Resolution);
		if (_sur != _surOld)
		{
			Sides[@ _side] = _sur;
		}
		return _sur;
	};

	/// @func ToSingleSurface(_surface, _clearColor, _clearAlpha)
	/// @desc Puts all faces of the cubemap into a single surface.
	/// @param {uint} _clearColor
	/// @param {real} _clearAlpha
	/// @see Cubemap.Surface
	static ToSingleSurface = function (_clearColor, _clearAlpha)
	{
		Surface = CheckSurface(Surface, Resolution * 8, Resolution);
		surface_set_target(Surface);
		draw_clear_alpha(_clearColor, _clearAlpha);
		var _x = 0;
		var i = 0;
		repeat (ECubeSide.SIZE)
		{
			draw_surface(Sides[i++], _x, 0);
			_x += Resolution;
		}
		surface_reset_target();
	};

	/// @func GetViewMatrix(_side)
	/// @desc Creates a view matrix for given cubemap side.
	/// @param {ECubemapSide} side The cubemap side.
	/// @return {matrix} The created view matrix.
	static GetViewMatrix = function (_side)
	{
		var _negEye = Position.Scale(-1);
		var _x, _y, _z;

		switch (_side)
		{
		case ECubeSide.PosX:
			_x = new Vec3(0, +1, 0);
			_y = new Vec3(0, 0, +1);
			_z = new Vec3(+1, 0, 0);
			break;

		case ECubeSide.NegX:
			_x = new Vec3(0, -1, 0);
			_y = new Vec3(0, 0, +1);
			_z = new Vec3(-1, 0, 0);
			break;

		case ECubeSide.PosY:
			_x = new Vec3(-1, 0, 0);
			_y = new Vec3(0, 0, +1);
			_z = new Vec3(0, +1, 0);
			break;

		case ECubeSide.NegY:
			_x = new Vec3(+1, 0, 0);
			_y = new Vec3(0, 0, +1);
			_z = new Vec3(0, -1, 0);
			break;

		case ECubeSide.PosZ:
			_x = new Vec3(0, +1, 0);
			_y = new Vec3(-1, 0, 0);
			_z = new Vec3(0, 0, +1);
			break;

		case ECubeSide.NegZ:
			_x = new Vec3(0, +1, 0);
			_y = new Vec3(+1, 0, 0);
			_z = new Vec3(0, 0, -1);
			break;
		}

		return [
			_x.X, _y.X, _z.X, 0,
			_x.Y, _y.Y, _z.Y, 0,
			_x.Z, _y.Z, _z.Z, 0,
			_x.Dot(_negEye), _y.Dot(_negEye), _z.Dot(_negEye), 1
		];
	}

	/// @func GetProjectionMatrix()
	/// @desc Creates a projection matrix for the cubemap.
	/// @return {matrix} The created projection matrix.
	static GetProjectionMatrix = function ()
	{
		gml_pragma("forceinline");
		return matrix_build_projection_perspective_fov(90, 1, ZNear, ZFar);
	};

	/// @func SetTarget()
	/// @desc Sets next cubemap side surface as the render target and sets
	/// the current view and projection matrices appropriately.
	/// @return {bool} Returns `true` if the render target was set or `false`
	/// if all cubemap sides were iterated through,
	/// @example
	/// ```gml
	/// while (cubemap.SetTarget())
	/// {
	///     draw_clear(c_black);
	///     // Render to cubemap here...
	///     cubemap.ResetTarget();
	/// }
	/// ```
	/// @see Cubemap.ResetTarget
	static SetTarget = function ()
	{
		var _renderTo = RenderTo++;
		if (_renderTo < ECubeSide.SIZE)
		{
			surface_set_target(GetSurface(_renderTo));
			matrix_set(matrix_view, GetViewMatrix(_renderTo));
			matrix_set(matrix_projection, GetProjectionMatrix());
			return true;
		}
		RenderTo = 0;
		return false;
	};

	/// @func ResetTarget()
	/// @desc Resets the render target.
	/// @see Cubemap.SetTarget
	static ResetTarget = function ()
	{
		gml_pragma("forceinline");
		surface_reset_target();
	};

	/// @func Destroy()
	/// @desc Frees memory used by the cubemap.
	static Destroy = function ()
	{
		var i = 0;
		repeat (ECubeSide.SIZE)
		{
			var _surface = Sides[i++];
			if (surface_exists(_surface))
			{
				surface_free(_surface);
			}
		}
	};
}