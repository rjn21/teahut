// Bildschirm-Vignette mit leichtem Farbstich an den Rändern (typisch HD-2D).
shader_type canvas_item;
uniform float strength : hint_range(0.0, 1.0) = 0.45;
uniform vec4 edge_color : source_color = vec4(0.06, 0.03, 0.10, 1.0);
uniform float inner = 0.30;
uniform float outer = 0.85;

void fragment() {
	vec2 uv = SCREEN_UV - 0.5;
	uv.x *= 1.2;
	float v = smoothstep(inner, outer, length(uv) * 1.35);
	COLOR = vec4(edge_color.rgb, v * strength);
}
