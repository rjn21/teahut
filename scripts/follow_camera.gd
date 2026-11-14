extends Camera3D

@export var target: Node3D

var offset: Vector3


func _ready() -> void:
	if target == null:
		push_error("Der Kamera fehlt eine Zielfigur.")
		set_process(false)
		return

	offset = global_position - target.global_position

func _process(_delta: float) -> void:
	global_position = target.global_position + offset
