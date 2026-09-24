@tool
class_name TimeOfDayLighting
extends Node
## Stimmungslicht über den Tag: Sonne/Mond, Umgebungslicht, Nebel, Wasserfarbe
## und Laternen (Gruppe "night_light"). Setze `hour` aus deinem Uhr-Skript (M7).
## Im Editor sofort sichtbar – einfach am Regler ziehen.

@export var sun: DirectionalLight3D
@export var world_environment: WorldEnvironment
@export_range(0.0, 24.0, 0.05) var hour: float = 15.0:
	set(v):
		hour = fposmod(v, 24.0)
		_apply()
@export_range(0.0, 1.0, 0.01) var rain_amount: float = 0.0:
	set(v):
		rain_amount = v
		_apply()
@export var sun_yaw_degrees: float = 32.0

# Stunde, Sonnenhöhe, Lichtfarbe, Energie, Umgebungsfarbe, Umgebungsenergie, Nebel/Hintergrund, Wasser-Tint, Nacht
const KEYS := [
	[0.0, 38.0, Color(0.55, 0.62, 1.0), 0.28, Color(0.26, 0.30, 0.52), 0.55, Color(0.07, 0.08, 0.16), Color(0.30, 0.36, 0.60), 1.0],
	[5.0, 30.0, Color(0.55, 0.62, 1.0), 0.25, Color(0.28, 0.30, 0.50), 0.55, Color(0.08, 0.09, 0.18), Color(0.30, 0.36, 0.60), 1.0],
	[6.5, 10.0, Color(1.0, 0.68, 0.50), 0.80, Color(0.62, 0.55, 0.62), 0.65, Color(0.85, 0.66, 0.60), Color(0.85, 0.75, 0.80), 0.5],
	[9.0, 42.0, Color(1.0, 0.94, 0.84), 1.25, Color(0.66, 0.72, 0.80), 0.80, Color(0.78, 0.84, 0.88), Color(1.0, 1.0, 1.0), 0.0],
	[15.0, 48.0, Color(1.0, 0.93, 0.80), 1.30, Color(0.70, 0.72, 0.78), 0.80, Color(0.82, 0.84, 0.86), Color(1.0, 1.0, 1.0), 0.0],
	[18.3, 14.0, Color(1.0, 0.60, 0.34), 1.10, Color(0.78, 0.56, 0.55), 0.70, Color(1.0, 0.64, 0.46), Color(1.0, 0.80, 0.66), 0.35],
	[20.0, 24.0, Color(0.58, 0.62, 1.0), 0.32, Color(0.32, 0.33, 0.56), 0.58, Color(0.10, 0.10, 0.20), Color(0.34, 0.38, 0.64), 1.0],
	[24.0, 38.0, Color(0.55, 0.62, 1.0), 0.28, Color(0.26, 0.30, 0.52), 0.55, Color(0.07, 0.08, 0.16), Color(0.30, 0.36, 0.60), 1.0],
]


func _ready() -> void:
	_apply()


func _apply() -> void:
	if not is_inside_tree():
		return
	var a: Array = KEYS[0]
	var b: Array = KEYS[1]
	for i in range(KEYS.size() - 1):
		if hour >= KEYS[i][0] and hour <= KEYS[i + 1][0]:
			a = KEYS[i]
			b = KEYS[i + 1]
			break
	var h0: float = a[0]
	var h1: float = b[0]
	var t: float = 0.0 if is_equal_approx(h0, h1) else (hour - h0) / (h1 - h0)
	t = t * t * (3.0 - 2.0 * t)
	var pitch: float = lerpf(a[1], b[1], t)
	var lcol: Color = (a[2] as Color).lerp(b[2], t)
	var energy: float = lerpf(a[3], b[3], t)
	var acol: Color = (a[4] as Color).lerp(b[4], t)
	var aen: float = lerpf(a[5], b[5], t)
	var fog: Color = (a[6] as Color).lerp(b[6], t)
	var tint: Color = (a[7] as Color).lerp(b[7], t)
	var night: float = lerpf(a[8], b[8], t)

	# Regen: gedämpft, kühler, grauer
	var r: float = rain_amount
	energy *= lerpf(1.0, 0.45, r)
	lcol = lcol.lerp(Color(0.75, 0.8, 0.9), r * 0.6)
	acol = acol.lerp(Color(0.5, 0.55, 0.65), r * 0.5)
	fog = fog.lerp(Color(0.55, 0.6, 0.66), r * 0.6)
	tint = tint.lerp(Color(0.72, 0.78, 0.85), r * 0.6)
	night = maxf(night, r * 0.45)

	if sun:
		sun.rotation_degrees = Vector3(-pitch, sun_yaw_degrees, 0.0)
		sun.light_color = lcol
		sun.light_energy = energy
	if world_environment and world_environment.environment:
		var env := world_environment.environment
		env.ambient_light_color = acol
		env.ambient_light_energy = aen
		env.background_color = fog
		env.fog_light_color = fog
	if Engine.is_editor_hint():
		for n in get_tree().get_nodes_in_group("night_light"):
			if n.has_method("set_night_amount"):
				n.set_night_amount(night)
	else:
		get_tree().call_group("night_light", "set_night_amount", night)
	for w in get_tree().get_nodes_in_group("hd2d_water"):
		if w is GeometryInstance3D and w.material_override is ShaderMaterial:
			(w.material_override as ShaderMaterial).set_shader_parameter("tint", tint)
