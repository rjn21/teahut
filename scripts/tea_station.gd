class_name TeaStation
extends Interactable
## Teestation in der Hütte (Spec 7). Hält Zustand, Zeiten und Spielstand der Zubereitung.
## Bedient wird sie über die Nahansicht (TeaStationCloseUp): E an der Station öffnet sie,
## jeder Handgriff ist eine eigene Funktion, die nur im passenden Zustand etwas tut.
## Die Kräuterportion wird beim Befüllen des Siebs aus dem Inventar genommen (reserviert)
## und beim Zurücksetzen zurückgegeben.

signal close_up_requested
## Jede Änderung, die die Nahansicht neu zeichnen muss (Zustand, Sorte, Timer).
signal brewing_changed
## Der Tee ist fertig gezogen und der Timer war eingeschaltet. Kommt höchstens einmal pro Tasse.
signal timer_rang(tea: TeaData)

enum BrewState {
	EMPTY,
	HERBS_IN_STRAINER,
	STRAINER_IN_CUP,
	HEATING,
	WATER_HOT,
	STEEPING,
	STEEPED,
	CUP_READY,
}

## Zustandsnamen der vereinfachten Station bis M6e → heutiger Zustand.
const LEGACY_STATE_NAMES := {
	"IDLE": "EMPTY",
	"BREWING": "STEEPING",
	"READY": "CUP_READY",
}
## Zustände, in denen eine Kräuterportion im Sieb steckt, die Zurücksetzen zurückgibt.
const STATES_WITH_RESERVED_HERBS := [
	BrewState.HERBS_IN_STRAINER,
	BrewState.STRAINER_IN_CUP,
	BrewState.HEATING,
	BrewState.WATER_HOT,
	BrewState.STEEPING,
	BrewState.STEEPED,
]

@export var teas: Array[TeaData] = []
## Wählbare Wassertemperaturen in °C (Spec 11). Alle ergeben denselben Tee.
@export var temperatures: Array[int] = [80, 90, 100]
@export var heating_duration: float = 5.0

var tea_index: int = 0
var tea: TeaData:
	get:
		return teas[tea_index]

var state: BrewState = BrewState.EMPTY
## Restzeit des Erhitzens bzw. Ziehens in Sekunden.
var remaining: float = 0.0
## Gewählte Wassertemperatur in °C; 0, solange keine gewählt ist.
var temperature: int = 0
var timer_enabled: bool = false


func _ready() -> void:
	assert(not teas.is_empty(), "Teestation: keine TeaData zugewiesen")
	add_to_group("persist")
	interaction_label.visible = false
	update_interaction_label()


func _process(delta: float) -> void:
	if state != BrewState.HEATING and state != BrewState.STEEPING:
		return
	remaining -= delta
	if remaining > 0.0:
		return
	remaining = 0.0
	if state == BrewState.HEATING:
		_set_state(BrewState.WATER_HOT)
	else:
		_set_state(BrewState.STEEPED)
		if timer_enabled:
			timer_rang.emit(tea)


func interact() -> void:
	close_up_requested.emit()


func update_interaction_label() -> void:
	match state:
		BrewState.EMPTY:
			interaction_label.text = "E - Tee zubereiten"
		BrewState.HEATING:
			interaction_label.text = "Wasser wird heiß · E - ansehen"
		BrewState.WATER_HOT:
			interaction_label.text = "Wasser ist heiß · E - eingießen"
		BrewState.STEEPING:
			interaction_label.text = "%s zieht · E - ansehen" % tea.display_name
		BrewState.STEEPED:
			interaction_label.text = "%s ist fertig · E - Sieb herausnehmen" % tea.display_name
		BrewState.CUP_READY:
			interaction_label.text = "E - %s abholen" % tea.display_name
		_:
			interaction_label.text = "E - weiter zubereiten"


# --- Handgriffe (Spec 7, Ablauf 1–7) ---

func has_herbs_for(tea_to_brew: TeaData) -> bool:
	return Inventory.get_count(tea_to_brew.herb.id) >= tea_to_brew.herb_amount


## 1. Kräuterglas: reserviert eine Portion und füllt sie ins Sieb.
func fill_strainer(tea_to_brew: TeaData) -> bool:
	if state != BrewState.EMPTY:
		return false
	if not Inventory.try_take_item(tea_to_brew.herb.id, tea_to_brew.herb_amount):
		return false
	tea_index = teas.find(tea_to_brew)
	temperature = 0
	_set_state(BrewState.HERBS_IN_STRAINER)
	return true


## 2. Sieb in die Tasse stellen.
func insert_strainer() -> void:
	if state == BrewState.HERBS_IN_STRAINER:
		_set_state(BrewState.STRAINER_IN_CUP)


## 3. und 4. Temperatur wählen und Wasserkocher einschalten.
func start_heating(chosen_temperature: int) -> void:
	if state != BrewState.STRAINER_IN_CUP:
		return
	temperature = chosen_temperature
	remaining = heating_duration
	_set_state(BrewState.HEATING)


## 5. Eingießen; die Ziehzeit beginnt sofort.
func pour_water() -> void:
	if state != BrewState.WATER_HOT:
		return
	remaining = tea.brew_duration
	_set_state(BrewState.STEEPING)


## 7. Sieb herausnehmen, sobald der Tee gezogen hat.
func remove_strainer() -> void:
	if state == BrewState.STEEPED:
		_set_state(BrewState.CUP_READY)


## 7. Fertige Tasse abholen: genau eine Tasse ins Inventar, Station wieder frei.
func collect_tea() -> void:
	if state != BrewState.CUP_READY:
		return
	Inventory.add_item(tea.id, 1)
	_set_state(BrewState.EMPTY)


func can_reset() -> bool:
	return state in STATES_WITH_RESERVED_HERBS


## Bricht die Zubereitung ab und gibt die reservierte Kräuterportion zurück.
func reset_brewing() -> void:
	if not can_reset():
		return
	Inventory.add_item(tea.herb.id, tea.herb_amount)
	remaining = 0.0
	temperature = 0
	_set_state(BrewState.EMPTY)


func set_timer_enabled(value: bool) -> void:
	timer_enabled = value
	brewing_changed.emit()


## Fortschritt des Erhitzens bzw. Ziehens von 0 bis 1; in anderen Zuständen 0.
func get_progress() -> float:
	var duration: float = _current_duration()
	if duration <= 0.0:
		return 0.0
	return clampf(1.0 - remaining / duration, 0.0, 1.0)


func _current_duration() -> float:
	match state:
		BrewState.HEATING:
			return heating_duration
		BrewState.STEEPING:
			return tea.brew_duration
	return 0.0


func _set_state(new_state: BrewState) -> void:
	state = new_state
	update_interaction_label()
	brewing_changed.emit()


# --- Spielstand ---

func get_save_data() -> Dictionary:
	return {
		"state": BrewState.keys()[state],
		"remaining": remaining,
		"tea": tea.id,
		"temperature": temperature,
		"timer_enabled": timer_enabled,
	}


func load_save_data(data: Dictionary) -> void:
	var state_name: String = str(data.get("state", "EMPTY"))
	state_name = LEGACY_STATE_NAMES.get(state_name, state_name)
	state = BrewState.get(state_name, BrewState.EMPTY)

	tea_index = _find_tea_index(str(data.get("tea", "")))
	temperature = int(data.get("temperature", 0))
	timer_enabled = bool(data.get("timer_enabled", false))

	var saved_remaining: float = float(data.get("remaining", _current_duration()))
	remaining = clampf(saved_remaining, 0.0, _current_duration())
	update_interaction_label()
	brewing_changed.emit()


func _find_tea_index(id: String) -> int:
	for i in teas.size():
		if teas[i].id == id:
			return i
	return 0
