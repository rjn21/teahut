extends Area3D

enum  PlotState {
	EMPTY,
	GROWING,
	READY
}

@export var herb: HerbData

var state: PlotState = PlotState.EMPTY
var player_in_range: bool = false
var remaining: float = 0.0

@onready var interaction_label: Label3D = $InteractionLabel
@onready var bed_visual: HerbPlantVisual = $GardenBed

func _ready() -> void:
	assert(herb != null, "Beet: keine HerbData zugewiesen")
	add_to_group("persist")
	interaction_label.visible = false
	bed_visual.herb = herb.id
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	update_interaction_label()
	update_visual()	

func _process(delta: float) -> void:
	if state == PlotState.GROWING:
		remaining -= delta
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
		
func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
		interaction_label.visible = false
		
func interact() -> void:
	match state:
		PlotState.EMPTY:
			plant()
		PlotState.GROWING:
			pass
		PlotState.READY:
			harvest()

func plant() -> void:
	state = PlotState.GROWING
	remaining = herb.growth_duration
	update_interaction_label()
	update_visual()
	
func harvest() -> void:
	state =PlotState.EMPTY
	remaining = 0.0
	Inventory.add_item(herb.id, herb.harvest_amount)
	update_interaction_label()
	update_visual()
	
func _on_growth_finished() -> void:
	state = PlotState.READY
	remaining = 0.0
	update_interaction_label()
	update_visual()
	
func update_interaction_label() -> void:
	match state:
		PlotState.EMPTY:
			interaction_label.text = "E - %s pflanzen" % herb.display_name
		PlotState.GROWING:
			interaction_label.text = "%s wächst" % herb.display_name
		PlotState.READY:
			interaction_label.text = "E - %s ernten" % herb.display_name
			
func update_visual() -> void:
	var progress:= 0.0
	if state == PlotState.GROWING and herb.growth_duration > 0.0:
		progress = 1.0 - remaining / herb.growth_duration
	bed_visual.set_from_state(state, progress)

#	--- Spielstand ---
	
func get_save_data() -> Dictionary:
	return {
		"state": PlotState.keys()[state],
		"remaining": remaining
	}

func load_save_data(data: Dictionary) -> void:
	var state_name: String = str(data.get("state", "EMPTY"))
	state = PlotState.get(state_name, PlotState.EMPTY)
	
	var remaining_float: float = float(data.get("remaining", herb.growth_duration))
	remaining = clampf(remaining_float, 0.0, herb.growth_duration)
	update_interaction_label()
	update_visual()
