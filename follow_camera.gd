extends Camera3D

@export var target: Node3D

var offset: Vector3



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target == null:
		push_error("Der Kamera fehlt eine Zielfigur.")
		set_physics_process(false)
		return
		
	offset = global_position - target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = target.global_position + offset
