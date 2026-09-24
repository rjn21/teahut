// HD-2D-Boden: Pixel-genaue Mischung aus Gras, Weg, Sand und abgesenktem Seegrund.
// Die Maske (R = Weg, G = Sand, B = Wasser) wird weich gezeichnet; dieser Shader
// macht daraus unregelmäßige, pixelige Kanten. Die Maske kannst du in jedem
// Malprogramm bearbeiten.
shader_type spatial;
render_mode specular_disabled;

uniform sampler2D grass_a : source_color, filter_nearest_mipmap, repeat_enable;
uniform sampler2D grass_b : source_color, filter_nearest_mipmap, repeat_enable;
uniform sampler2D path_tex : source_color, filter_nearest_mipmap, repeat_enable;
uniform sampler2D sand_tex : source_color, filter_nearest_mipmap, repeat_enable;
uniform sampler2D mask : filter_linear, repeat_disable;
uniform vec2 map_origin = vec2(-24.0, -24.0);
uniform vec2 map_size = vec2(48.0, 48.0);
uniform float texels_per_meter = 32.0;
uniform float texture_meters = 2.0;
uniform float water_depth = 0.9;
uniform float edge_noise = 0.35;
uniform vec4 lakebed_tint : source_color = vec4(0.45, 0.55, 0.55, 1.0);

varying vec3 wpos;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float bayer4(vec2 p) {
	ivec2 i = ivec2(mod(floor(p), 4.0));
	int idx = i.x + i.y * 4;
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[idx]) + 0.5) / 16.0;
}

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 muv = (w.xz - map_origin) / map_size;
	float water = textureLod(mask, muv, 0.0).b;
	VERTEX.y -= smoothstep(0.3, 0.7, water) * water_depth;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 pix = floor(wpos.xz * texels_per_meter);
	vec2 p = (pix + 0.5) / texels_per_meter;
	vec4 m = texture(mask, (p - map_origin) / map_size);
	float n = vnoise(p * 1.4) * 0.6 + vnoise(p * 4.5) * 0.4 - 0.5;
	float b = bayer4(pix);

	vec2 tuv = p / texture_meters;
	vec3 col = texture(grass_a, tuv).rgb;
	float patch = smoothstep(0.35, 0.7, vnoise(p * 0.16) * 0.8 + vnoise(p * 0.5) * 0.2);
	if (patch > b) {
		col = texture(grass_b, tuv + vec2(0.375, 0.625)).rgb;
	}
	float sand = m.g + n * edge_noise;
	float path = m.r + n * edge_noise;
	float water = m.b + n * edge_noise * 0.5;
	if (sand > 0.5) {
		col = texture(sand_tex, tuv).rgb;
		if (sand < 0.56) col *= 0.82;
	}
	if (path > 0.5) {
		col = texture(path_tex, tuv).rgb;
		if (path < 0.55) col *= 0.8;
	}
	if (water > 0.42) {
		col = texture(sand_tex, tuv).rgb * lakebed_tint.rgb;
	}
	ALBEDO = col;
	ROUGHNESS = 1.0;
}
