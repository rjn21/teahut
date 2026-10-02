extends CharacterBody3D

@export var move_speed: float = 4.0

@onready var interaction_area: Area3D = $InteractionArea

var current_target: Interactable = null

func _ready() -> void:
	add_to_group("persist")
	
func _process(_delta: float) -> void:
	_set_target(_find_nearest_interactable())
	if current_target == null:
		return
	if Input.is_action_just_pressed("interact"):
		current_target.interact()
	elif Input.is_action_just_pressed("cycle"):
		current_target.cycle()
		
		
func _find_nearest_interactable() -> Interactable:
	var nearest: Interactable = null
	var best_distance: float = INF
	for area in interaction_area.get_overlapping_areas():
		if area is Interactable:
			var distance: float = global_position.distance_squared_to(area.global_position)
			if distance < best_distance:
				best_distance = distance
				nearest = area as Interactable
	return nearest
	

func _set_target(new_target: Interactable) -> void:
	if new_target == current_target:
		return
	var old_target: Interactable = current_target
	if old_target != null:
		old_target.set_focused(false)
	if new_target != null:
		new_target.set_focused(true)
	current_target = new_target

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
