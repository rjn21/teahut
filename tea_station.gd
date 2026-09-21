extends Area3D

var player_in_range: bool = false
var state: TeaState = TeaState.IDLE

enum TeaState {
	IDLE,
	BREWING,
	READY
}

@onready var interaction_label: Label3D = $InteractionLabel
@onready var brew_timer: Timer = $BrewTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_label.visible = false
	update_interaction_label()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	brew_timer.timeout.connect(_on_brew_finished)
	
	
func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true
		update_interaction_label()
		interaction_label.visible = true
		
func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
		interaction_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

# Lässt User interagieren abhängig vom Status
func interact() -> void:
	match state:
		TeaState.IDLE:
			start_brewing()
		TeaState.BREWING:
			pass
		TeaState.READY:
			collect_tea()

# 
func start_brewing() -> void:
	if not Inventory.try_take_mint(1):
		interaction_label.text = "Keine Minze vorhanden"
		return
	
	state = TeaState.BREWING
	brew_timer.start()
	update_interaction_label()
	
func _on_brew_finished() -> void:
	if state != TeaState.BREWING:
		return
	
	state = TeaState.READY
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
	
