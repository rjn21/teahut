@tool
extends Camera3D
## Feste HD-2D-Kamera: schmales Sichtfeld, schräger Blick, folgt einem Ziel weich.
## Die Tiefenunschärfe (Tilt-Shift) wird automatisch auf das Ziel scharf gestellt.

@export var target: Node3D
@export_range(10.0, 60.0) var distance: float = 19.0
@export_range(10.0, 70.0) var pitch_degrees: float = 33.0
@export var look_offset: Vector3 = Vector3(0, 0.8, 0)
@export var follow_smoothing: float = 6.0
@export var focus_near_margin: float = 5.0 ## Alles näher als Ziel − Wert wird weich
@export var focus_far_margin: float = 7.0 ## Alles weiter als Ziel + Wert wird weich

var _focus: Vector3


func _ready() -> void:
	if target:
		_focus = target.global_position + look_offset
	_place(1.0)


func _process(delta: float) -> void:
	if target == null:
		return
	var goal := target.global_position + look_offset
	if Engine.is_editor_hint():
		_focus = goal
	else:
		_focus = _focus.lerp(goal, 1.0 - exp(-follow_smoothing * delta))
	_place(delta)


func _place(_delta: float) -> void:
	var p := deg_to_rad(pitch_degrees)
	var offset := Vector3(0.0, sin(p), cos(p)) * distance
	global_position = _focus + offset
	rotation = Vector3(-p, 0.0, 0.0)
	if attributes is CameraAttributesPractical:
		var a := attributes as CameraAttributesPractical
		a.dof_blur_far_distance = distance + focus_far_margin
		a.dof_blur_near_distance = maxf(0.5, distance - focus_near_margin)
