extends Area3D

enum  PlotState {
	EMPTY,
	GROWING,
	READY
}

@export var growth_duration: float = 5.0

var state: PlotState = PlotState.EMPTY
var player_in_range: bool = false
var remaining: float = 0.0

@onready var interaction_label: Label3D = $InteractionLabel
@onready var growth_timer: Timer = $GrowthTimer
@onready var bed_visual: HerbPlantVisual = $GardenBed


func _process(_delta: float) -> void:
	if state == PlotState.GROWING:
		remaining -= _delta
		if remaining <= 0.0:
			_on_growth_finished()
		else:
			update_visual()
	
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true
		interaction_label.visible = true
		
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
	remaining = growth_duration
	print("Minze gepflanzt")	
	update_interaction_label()
	update_visual()
	
func harvest_mint() -> void:
	state =PlotState.EMPTY
	remaining = 0.0
	Inventory.add_mint(2)
	print("Minze geerntet.")
	update_interaction_label()
	update_visual()
	
func _on_growth_finished() -> void:
	state = PlotState.READY
	remaining = 0.0
	update_interaction_label()
	update_visual()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	update_interaction_label()
	update_visual()	
		
func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
		interaction_label.visible = false
	
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
	if state == PlotState.GROWING and growth_duration > 0.0:
		progress = 1.0 - remaining / growth_duration
	bed_visual.set_from_state(state, progress)
		

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
