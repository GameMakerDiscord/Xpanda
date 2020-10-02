/// @func Vec2([x[, y]])
/// @param {real} [_x]
/// @param {real} [_y]
function Vec2() constructor
{
	/// @var {real}
	X = (argument_count > 0) ? argument[0] : 0;

	/// @var {real}
	Y = (argument_count > 1) ? argument[1] : X;

	/// @func Clone()
	/// @return {Vec2}
	static Clone = function ()
	{
		gml_pragma("forceinline");
		return new Vec2(X, Y, Z);
	};

	/// @func Length()
	/// @return {real}
	static Length = function ()
	{
		gml_pragma("forceinline");
		return sqrt((X * X) + (Y * Y));
	};

	/// @func LengthSqr()
	/// @return {real}
	static LengthSqr = function ()
	{
		gml_pragma("forceinline");
		return ((X * X) + (Y * Y));
	};

	/// @func Normalize()
	/// @return {Vec2}
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
	/// @param {Vec2} _vector
	/// @return {Vec2}
	static Add = function (_vector)
	{
		gml_pragma("forceinline");
		return new Vec2(
			X + _vector.X,
			Y + _vector.Y);
	};

	/// @func Subtract(_vector)
	/// @param {Vec2} _vector
	/// @return {Vec2}
	static Subtract = function (_vector)
	{
		gml_pragma("forceinline");
		return new Vec2(
			X - _vector.X,
			Y - _vector.Y);
	};

	/// @func Scale(_scale)
	/// @param {real} _scale
	/// @return {Vec2}
	static Scale = function (_scale)
	{
		gml_pragma("forceinline");
		return new Vec2(X * _scale, Y * _scale);
	};

	/// @func Dot(_vector)
	/// @param {Vec2} _vector
	/// @return {float}
	static Dot = function (_vector)
	{
		gml_pragma("forceinline");
		return ((X * _vector.X)
			+ (Y * _vector.Y));
	};
}