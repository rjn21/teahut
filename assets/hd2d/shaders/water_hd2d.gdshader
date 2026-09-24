// HD-2D-Wasser: pixelige Wellen, Glitzerstreifen und Schaum am Ufer.
// Undurchsichtig (damit Tiefenunschärfe und SSAO sauber bleiben).
// Mit Maske (B-Kanal = Wasser) entsteht Schaum und Tiefe am Ufer automatisch.
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 shallow_color : source_color = vec4(0.38, 0.68, 0.72, 1.0);
uniform vec4 deep_color : source_color = vec4(0.14, 0.34, 0.50, 1.0);
uniform vec4 foam_color : source_color = vec4(0.92, 0.97, 0.95, 1.0);
uniform vec4 glint_color : source_color = vec4(0.82, 0.94, 0.98, 1.0);
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float pixels_per_meter = 16.0;
uniform float wave_speed = 0.25;
uniform bool use_mask = true;
uniform sampler2D mask : filter_linear, repeat_disable;
uniform vec2 map_origin = vec2(-24.0, -24.0);
uniform vec2 map_size = vec2(48.0, 48.0);

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
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 pix = floor(wpos.xz * pixels_per_meter);
	vec2 p = (pix + 0.5) / pixels_per_meter;
	float t = floor(TIME * 8.0) / 8.0 * wave_speed;   // ruckelige Pixel-Animation

	float depth = 1.0;
	float shore = 0.0;
	if (use_mask) {
		float w = texture(mask, (p - map_origin) / map_size).b;
		depth = smoothstep(0.45, 0.95, w);
		shore = 1.0 - smoothstep(0.42, 0.52, w + (vnoise(p * 3.0 + t * 2.0) - 0.5) * 0.12);
	}
	float b = bayer4(pix);
	vec3 col = mix(shallow_color.rgb, deep_color.rgb, step(b, depth) * 0.6 + depth * 0.4);

	// sanfte Wellenbänder
	float band = vnoise(vec2(p.x * 0.7 + t, p.y * 2.6 - t * 0.6));
	if (band > 0.62) col = mix(col, shallow_color.rgb * 1.12, 0.6);
	if (band < 0.25) col *= 0.92;
	// Glitzerstreifen
	float g = vnoise(vec2(p.x * 1.6 - t * 1.7, p.y * 5.0 + t * 0.4));
	if (g > 0.8 && hash(pix + floor(TIME * 3.0)) > 0.35) col = glint_color.rgb;
	// Schaum am Ufer
	if (shore > b) col = foam_color.rgb;

	ALBEDO = col * tint.rgb;
}
