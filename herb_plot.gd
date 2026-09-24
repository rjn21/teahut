extends Area3D

enum  PlotState {
	EMPTY,
	GROWING,
	READY
}

var state: PlotState = PlotState.EMPTY

var player_in_range: bool = false

@onready var interaction_label: Label3D = $InteractionLabel
@onready var growth_timer: Timer = $GrowthTimer
@onready var bed_visual: HerbPlantVisual = $GardenBed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	growth_timer.timeout.connect(_on_growth_finished)
	update_visual()
	
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
		PlotState.EMPTY:
			plant_mint()
		PlotState.GROWING:
			print("Die Minze wächst noch")
		PlotState.READY:
			harvest_mint()
			
func plant_mint() -> void:
	state = PlotState.GROWING
	growth_timer.start()
	
	print("Minze gepflanzt.")
	
	update_interaction_label()
	update_visual()
	
func harvest_mint() -> void:
	state =PlotState.EMPTY
	Inventory.add_mint(2)
	print("Minze geerntet.")
	update_interaction_label()
	update_visual()
	
func update_interaction_label() -> void:
	match state:
		PlotState.EMPTY:
			interaction_label.text = "E - Minze pflanzen"
		PlotState.GROWING:
			interaction_label.text = "Minze wächst"
		PlotState.READY:
			interaction_label.text = "E - Minze ernten"
			
func update_visual() -> void:
	var progress:= 0.0
	if state == PlotState.GROWING:
		progress = 1.0 - growth_timer.time_left / growth_timer.wait_time
	bed_visual.set_from_state(state, progress)
		
func _on_growth_finished() -> void:
	state = PlotState.READY
	update_interaction_label()
	update_visual()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()
