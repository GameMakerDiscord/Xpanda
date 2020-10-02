/// @func Vec3([x[, y[, z]]])
/// @param {real} [_x]
/// @param {real} [_y]
/// @param {real} [_z]
function Vec3() constructor
{
	/// @var {real}
	X = (argument_count > 0) ? argument[0] : 0;

	/// @var {real}
	Y = (argument_count > 1) ? argument[1] : X;

	/// @var {real}
	Z = (argument_count > 2) ? argument[2] : Y;

	/// @func Clone()
	/// @return {Vec3}
	static Clone = function ()
	{
		gml_pragma("forceinline");
		return new Vec3(X, Y, Z);
	};

	/// @func Length()
	/// @return {real}
	static Length = function ()
	{
		gml_pragma("forceinline");
		return sqrt((X * X) + (Y * Y) + (Z * Z));
	};

	/// @func LengthSqr()
	/// @return {real}
	static LengthSqr = function ()
	{
		gml_pragma("forceinline");
		return ((X * X) + (Y * Y) + (Z * Z));
	};

	/// @func Normalize()
	/// @return {Vec3}
	static Normalize = function ()
	{
		gml_pragma("forceinline");
		var _lengthSqr = LengthSqr();
		if (_lengthSqr == 0)
		{
			return Clone();
		}
		return Scale(1 / sqrt(_lengthSqr));
	};

	/// @func Add(_vector)
	/// @param {Vec3} _vector
	/// @return {Vec3}
	static Add = function (_vector)
	{
		gml_pragma("forceinline");
		return new Vec3(
			X + _vector.X,
			Y + _vector.Y,
			Z + _vector.Z);
	};

	/// @func Subtract(_vector)
	/// @param {Vec3} _vector
	/// @return {Vec3}
	static Subtract = function (_vector)
	{
		gml_pragma("forceinline");
		return new Vec3(
			X - _vector.X,
			Y - _vector.Y,
			Z - _vector.Z);
	};

	/// @func Scale(_scale)
	/// @param {real} _scale
	/// @return {Vec3}
	static Scale = function (_scale)
	{
		gml_pragma("forceinline");
		return new Vec3(X * _scale, Y * _scale, Z * _scale);
	};

	/// @func Cross(_vector)
	/// @param {Vec3} _vector
	/// @return {Vec3}
	static Cross = function (_vector)
	{
		gml_pragma("forceinline");
		return new Vec3(
			(Y * _vector.Z) - (Z * _vector.Y),
			(Z * _vector.X) - (X * _vector.Z),
			(X * _vector.Y) - (Y * _vector.X));
	};

	/// @func Dot(_vector)
	/// @param {Vec3} _vector
	/// @return {float}
	static Dot = function (_vector)
	{
		gml_pragma("forceinline");
		return ((X * _vector.X)
			+ (Y * _vector.Y)
			+ (Z * _vector.Z));
	};
}