/// @param depth Non-linear depth.
/// @param zparam Equals (zfar / znear).
/// @return Linearized depth, in range 0..1.
float xLinearizeDepth(float depth, float zparam)
{
#if !defined(_YY_HLSL11_)
    depth = depth * 2.0 - 1.0;
#endif
    return 1.0 / ((1.0 - zparam) * depth + zparam);
}
