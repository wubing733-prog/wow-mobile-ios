shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D tex_rock : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_dirt : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_grass : source_color, filter_linear_mipmap, repeat_enable;
uniform float scale = 0.02;
uniform float blend_height = 40.0;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

vec3 triplanar(sampler2D tex, vec3 p, vec3 n) {
	vec3 bw = pow(abs(n), vec3(4.0));
	bw /= (bw.x + bw.y + bw.z);
	vec3 x = texture(tex, p.zy * scale).rgb;
	vec3 y = texture(tex, p.xz * scale).rgb;
	vec3 z = texture(tex, p.xy * scale).rgb;
	return x * bw.x + y * bw.y + z * bw.z;
}

void fragment() {
	vec3 n = normalize(world_normal);
	vec3 rock = triplanar(tex_rock, world_pos, n);
	vec3 dirt = triplanar(tex_dirt, world_pos, n);
	vec3 grass = triplanar(tex_grass, world_pos, n);
	// blend: low & steep -> rock/dirt, high & flat -> grass
	float slope = clamp(n.y, 0.0, 1.0);
	float h = clamp(world_pos.y / blend_height, 0.0, 1.0);
	float grass_w = smoothstep(0.55, 1.0, slope) * smoothstep(0.15, 0.8, h);
	vec3 base = mix(rock, dirt, 0.35);
	base = mix(base, grass, grass_w);
	ALBEDO = base;
	ROUGHNESS = 0.95;
	SPECULAR = 0.05;
}