extends CharacterBody3D

@export var move_speed: float = 4.0

func _ready() -> void:
	add_to_group("persist")

func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)
	
	velocity.x = input_direction.x * move_speed
	velocity.z = input_direction.y * move_speed
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	
# --- Spielstand ---

func get_save_data() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y, global_position.z]
	}
	
func load_save_data(data: Dictionary) -> void:
	var pos: Array = data.get("position", [])
	if pos.size() == 3:
		global_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
		velocity = Vector3.ZERO
