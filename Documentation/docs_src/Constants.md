# Constants
By default Xpanda defines following constants:

Constant  | Value
--------- | -----
`XGLSL`   | `true` if the target language is GLSL, otherwise `false`
`XHLSL`   | `true` if the target language is HLSL9 or HLSL11, otherwise `false`
`XHLSL9`  | `true` if the target language is HLSL9, otherwise `false`
`XHLSL11` | `true` if the target language is HLSL11, otherwise `false`

It is also possible to define custom constants through command line parameters.

**All occurrences of constants are automatically replaced by their values!**

Constants are especially handy in [branching](Branching.html), where they can be used to easily create shader permutations.
