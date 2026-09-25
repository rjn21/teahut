extends Area3D


enum TeaState {
	IDLE,
	BREWING,
	READY
}

@export var brew_duration: float = 5.0

var state: TeaState = TeaState.IDLE
var player_in_range: bool = false
var remaining: float = 0.0

@onready var interaction_label: Label3D = $InteractionLabel

func _ready() -> void:
	add_to_group("persist")
	interaction_label.visible = false
	update_interaction_label()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)	

func _process(delta: float) -> void:
	if state == TeaState.BREWING:
		remaining -= delta
		if remaining <= 0.0:
			_on_brew_finished()
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true
		update_interaction_label()
		interaction_label.visible = true
		
func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
		interaction_label.visible = false

func interact() -> void:
	match state:
		TeaState.IDLE:
			start_brewing()
		TeaState.BREWING:
			pass
		TeaState.READY:
			collect_tea()

func start_brewing() -> void:
	if not Inventory.try_take_mint(1):
		interaction_label.text = "Keine Minze vorhanden"
		return
	
	state = TeaState.BREWING
	remaining = brew_duration
	update_interaction_label()
	
func _on_brew_finished() -> void:
	if state != TeaState.BREWING:
		return
	state = TeaState.READY
	remaining = 0.0
	update_interaction_label()
	
func collect_tea() -> void:
	if state != TeaState.READY:
		return
	
	state = TeaState.IDLE
	Inventory.add_mint_tea(1)
	update_interaction_label()
	
# Aktualisiert die Label anhängig vom Status
func update_interaction_label() -> void:
	match state:
		TeaState.IDLE:
			interaction_label.text="E - Tee zubereiten"
		TeaState.BREWING:
			interaction_label.text = "Tee wird zubereitet"
		TeaState.READY:
			interaction_label.text = "E - Minztee abholen"
			
#	--- Spielstand ---
func get_save_data() -> Dictionary:
	return {
		"state": TeaState.keys()[state],
		"remaining": remaining
	}
	
func load_save_data(data: Dictionary) -> void:
	var state_name = data.get("state")
	state = TeaState.get(state_name, "IDLE")
	
	var remaining_float = float(data.get("remaining"))
	remaining = clampf(remaining_float, 0.0, brew_duration)
	
	update_interaction_label()
	
	
	
