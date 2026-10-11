extends Node3D

func _ready() -> void:
	var base := "res://assets/shadowfang/terrain_tex/"
	var sh := load("res://assets/shadowfang/terrain.gdshader")
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("tex_rock", load(base + "alteracrockbase_s.png"))
	m.set_shader_parameter("tex_dirt", load(base + "alteracdirtbase02_s.png"))
	m.set_shader_parameter("tex_grass", load(base + "alteracgrassbase2_s.png"))
	m.set_shader_parameter("scale", 0.02)
	m.set_shader_parameter("blend_height", 60.0)
	var t := get_node_or_null("Terrain") as MeshInstance3D
	if t: t.material_override = m

	var wm := ShaderMaterial.new()
	wm.shader = load("res://assets/shadowfang/wmo.gdshader")
	var texdir := "res://assets/shadowfang/textures/"
	var cand := ["ld_shadowfanginterior_038.png", "ld_shadowfanginterior_039.png", "ld_shadowfanginterior_019_lod1.png"]
	if ResourceLoader.exists(texdir + cand[0]):
		wm.set_shader_parameter("tex_stone", load(texdir + cand[0]))
	if ResourceLoader.exists(texdir + cand[1]):
		wm.set_shader_parameter("tex_wood", load(texdir + cand[1]))
	wm.set_shader_parameter("scale", 0.35)
	for n in ["Interior", "Exterior"]:
		var mi := get_node_or_null(n) as MeshInstance3D
		if mi: mi.material_override = wm

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color(0.35, 0.48, 0.72)
	psm.sky_horizon_color = Color(0.72, 0.74, 0.78)
	psm.ground_bottom_color = Color(0.18, 0.17, 0.15)
	psm.ground_horizon_color = Color(0.55, 0.54, 0.50)
	sky.sky_material = psm
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 1.1
	e.fog_enabled = true
	e.fog_light_color = Color(0.62, 0.66, 0.72)
	e.fog_density = 0.00012
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.35
	env.environment = e
	add_child(env)