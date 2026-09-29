extends Area3D

enum  PlotState {
	EMPTY,
	GROWING,
	READY
}

@export var herbs: Array[HerbData] = []

var herb_index: int = 0
var herb: HerbData:
	get:
		return herbs[herb_index]

var state: PlotState = PlotState.EMPTY
var player_in_range: bool = false
var remaining: float = 0.0

@onready var interaction_label: Label3D = $InteractionLabel
@onready var bed_visual: HerbPlantVisual = $GardenBed

func _ready() -> void:
	assert(not herbs.is_empty(), "Beet: keine Kräuter zugewiesen")
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
		
	if player_in_range and Input.is_action_just_pressed("cycle"):
		select_next_herb()

func select_next_herb() -> void:
	if state != PlotState.EMPTY:
		return
	herb_index = (herb_index + 1) % herbs.size()
	bed_visual.herb = herb.id
	update_interaction_label()

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
			interaction_label.text = "E - %s pflanzen · Q - Sorte wechseln" % herb.display_name
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
		"remaining": remaining,
		"herb": herb.id
	}

func load_save_data(data: Dictionary) -> void:
	var state_name: String = str(data.get("state", "EMPTY"))
	state = PlotState.get(state_name, PlotState.EMPTY)
	
	herb_index = _find_herb_index(str(data.get("herb", "")))
	bed_visual.herb = herb.id
	
	var remaining_float: float = float(data.get("remaining", herb.growth_duration))
	remaining = clampf(remaining_float, 0.0, herb.growth_duration)
	update_interaction_label()
	update_visual()
	
func _find_herb_index(id: String) -> int:
	for i in herbs.size():
		if herbs[i].id == id:
			return i
	return 0
