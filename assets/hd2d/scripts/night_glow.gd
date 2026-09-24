@tool
extends Node3D
## Lässt Leuchtobjekte (Laterne, Fenster) abends angehen.
## Wird von TimeOfDayLighting über die Gruppe "night_light" aufgerufen.
## Du kannst `lit` auch direkt setzen, z. B. wenn die Laterne gekauft wurde.

@export var glow_sprites: Array[NodePath] = []
@export var light: OmniLight3D
@export var light_energy: float = 1.6
@export var glow_strength: float = 1.6 ## > 1 erzeugt Bloom
@export var flicker: bool = true
@export var always_on: bool = false
@export var lit: bool = true:
	set(v):
		lit = v
		_apply()

var _night: float = 0.0
var _t: float = 0.0


func _ready() -> void:
	add_to_group("night_light")
	_apply()


func set_night_amount(f: float) -> void:
	_night = clampf(f, 0.0, 1.0)
	_apply()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not flicker or light == null or not light.visible:
		return
	_t += delta
	var n := sin(_t * 7.3) * 0.5 + sin(_t * 13.1 + 1.7) * 0.3 + sin(_t * 3.1) * 0.2
	light.light_energy = _energy() * (1.0 + n * 0.06)


func _energy() -> float:
	var f := 1.0 if always_on else _night
	return light_energy * f if lit else 0.0


func _apply() -> void:
	if not is_node_ready():
		return
	var f := (1.0 if always_on else _night) if lit else 0.0
	for p in glow_sprites:
		var s := get_node_or_null(p) as SpriteBase3D
		if s:
			s.visible = f > 0.01
			s.modulate = Color(glow_strength, glow_strength * 0.92, glow_strength * 0.8, f)
	if light:
		light.visible = f > 0.01
		light.light_energy = light_energy * f
