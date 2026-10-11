shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D tex_stone : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_wood : source_color, filter_linear_mipmap, repeat_enable;
uniform float scale = 0.35;

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
	vec3 stone = triplanar(tex_stone, world_pos, n);
	vec3 wood = triplanar(tex_wood, world_pos, n);
	float up = clamp(n.y, 0.0, 1.0);
	vec3 base = mix(stone, wood, smoothstep(0.75, 0.98, up) * 0.5);
	ALBEDO = base * vec3(1.05, 1.0, 0.95);
	ROUGHNESS = 0.9;
	SPECULAR = 0.1;
}