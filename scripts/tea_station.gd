extends Interactable

enum TeaState {
	IDLE,
	BREWING,
	READY
}

@export var teas: Array[TeaData] = []

var tea_index: int = 0
var tea: TeaData:
	get:
		return teas[tea_index]

var state: TeaState = TeaState.IDLE
var remaining: float = 0.0

func _ready() -> void:
	assert(not teas.is_empty(), "Teestation: keine TeaData zugewiesen")
	add_to_group("persist")
	interaction_label.visible = false
	update_interaction_label()

func _process(delta: float) -> void:
	if state == TeaState.BREWING:
		remaining -= delta
		if remaining <= 0.0:
			_on_brew_finished()

func interact() -> void:
	match state:
		TeaState.IDLE:
			start_brewing()
		TeaState.BREWING:
			pass
		TeaState.READY:
			collect_tea()

func start_brewing() -> void:
	if not Inventory.try_take_item(tea.herb.id, tea.herb_amount):
		interaction_label.text = "Keine %s vorhanden" % tea.herb.display_name
		return

	state = TeaState.BREWING
	remaining = tea.brew_duration
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
	Inventory.add_item(tea.id, 1)
	update_interaction_label()

func update_interaction_label() -> void:
	match state:
		TeaState.IDLE:
			interaction_label.text = "E - %s zubereiten · Q - Sorte wechseln" % tea.display_name
		TeaState.BREWING:
			interaction_label.text = "%s wird zubereitet" % tea.display_name
		TeaState.READY:
			interaction_label.text = "E - %s abholen" % tea.display_name

func select_next_tea() -> void:
	if state != TeaState.IDLE:
		return
		
	tea_index = (tea_index + 1) % teas.size()
	update_interaction_label()
	
func cycle() -> void:
	select_next_tea()

#	--- Spielstand ---

func get_save_data() -> Dictionary:
	return {
		"state": TeaState.keys()[state],
		"remaining": remaining,
		"tea": tea.id
	}
	
func _find_tea_index(id: String) -> int:
	for i in teas.size():
		if teas[i].id == id:
			return i
	return 0
			

func load_save_data(data: Dictionary) -> void:
	var state_name: String = str(data.get("state", "IDLE"))
	state = TeaState.get(state_name, TeaState.IDLE)

	tea_index = _find_tea_index(str(data.get("tea", "")))
	
	var remaining_float: float = float(data.get("remaining", tea.brew_duration))
	remaining = clampf(remaining_float, 0.0, tea.brew_duration)
	update_interaction_label()
