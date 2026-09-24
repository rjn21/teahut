extends Node
## Demo-Steuerung: 1 = Morgen, 2 = Nachmittag, 3 = Abend, 4 = Nacht, R = Regen an/aus,
## F = Zeit im Zeitraffer laufen lassen, H = Hilfe ein/aus.

@export var lighting: TimeOfDayLighting
@export var rain: GPUParticles3D
@export var help_label: Label

var _fast := false


func _ready() -> void:
	# Optional für Tests: godot -- --hour=22 --rain --pos=-6,-6
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hour="):
			lighting.hour = float(a.substr(7))
		elif a == "--rain":
			lighting.rain_amount = 1.0
			rain.emitting = true
		elif a.begins_with("--pos="):
			var p := a.substr(6).split(",")
			var pl := get_node("../Player") as Node3D
			pl.position = Vector3(float(p[0]), 0.0, float(p[1]))


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.physical_keycode:
		KEY_1: _go(7.5)
		KEY_2: _go(15.0)
		KEY_3: _go(18.4)
		KEY_4: _go(22.5)
		KEY_R:
			var on := lighting.rain_amount < 0.5
			create_tween().tween_property(lighting, "rain_amount", 1.0 if on else 0.0, 1.5)
			rain.emitting = on
		KEY_F: _fast = not _fast
		KEY_H: help_label.visible = not help_label.visible


func _process(delta: float) -> void:
	if _fast:
		lighting.hour += delta * 1.5


func _go(h: float) -> void:
	_fast = false
	var from := lighting.hour
	var to := h if h >= from else h + 24.0
	var tw := create_tween()
	tw.tween_method(func(x: float) -> void: lighting.hour = x, from, to, 1.6).set_trans(Tween.TRANS_SINE)
