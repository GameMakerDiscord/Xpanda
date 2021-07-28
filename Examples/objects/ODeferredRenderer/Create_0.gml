application_surface_enable(true);
application_surface_draw_enable(false);

gpu_set_alphatestenable(false);
gpu_set_tex_filter(true);
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_counterclockwise);

// GB | RGB                  | A
// -- | -------------------- | ------------
// 0  | Albedo/SpecularColor | AO
// 1  | Normal               | Roughness
// 2  | Depth                | Metalness
// 3  | Emissive             | Translucency

enum EGBuffer
{
	AlbedoAO,
	NormalRoughness,
	DepthMetalness,
	EmissiveTranslucency, // Emissive used for both emmisive materials and specular reflections!
	SIZE
};

for (var i = EGBuffer.SIZE - 1; i >= 0; --i)
{
	surGBuffer[i] = noone;
}

// SSAO
ssao_init(8, 4, 2);
ssaoResolution = 0.5;
surSsao = noone;
surWork = noone;

surLightBloom = noone;

// Camera
z = 1;
pitch = 0;
fov = 60;
clipNear = 1;
clipFar = 8192;
mouseXLast = 0;
mouseYLast = 0;

// Meshes
mesh_init();
var _mesh;

_mesh = mesh_load_obj("Models/LightPoint.obj");
vBufferLightPoint = mesh_to_vbuffer(_mesh, global.vBufferFormatBare);
mesh_destroy(_mesh);

_mesh = mesh_load_obj("Models/TestScene.obj");
mesh_recalculate_tbn(_mesh);
vBuffer = mesh_to_vbuffer(_mesh, global.vBufferFormat);
mesh_destroy(_mesh);