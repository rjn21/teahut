class_name TeaStationCloseUp
extends GameWindow
## Nahansicht der Teestation (Spec 7): Kräuterregal oben, darunter Sieb, Tasse,
## Wasserkocher mit Temperaturwahl und Sanduhr (Timer). Bedienung mit der Maus.
## Die Ansicht zeigt nur an und meldet Klicks an die TeaStation; Zustand und Zeiten hält die Station.
## Schließen mit E, Escape oder dem Knopf; die Zubereitung läuft dabei weiter.

const INTERACT_ACTION := "interact"
const JAR_SIZE := Vector2(96, 96)
const STEAM_FRAME_SIZE := Vector2(16, 24)
const STEAM_FRAME_COUNT := 4
const STEAM_FRAME_DURATION := 0.15
## Deckkraft für Dinge, die gerade nicht dran sind.
const INACTIVE_ALPHA := 0.4
## Wie kräftig der Tee schon beim Eingießen gefärbt ist (0 = klares Wasser, 1 = fertig).
const STEEPING_START_TINT := 0.3
const PICKED_UP_KETTLE_COLOR := Color(1.0, 0.92, 0.7)

@export var station: TeaStation
@export_group("Grafiken")
@export var cup_empty_texture: Texture2D
@export var cup_water_texture: Texture2D
@export var strainer_empty_texture: Texture2D
@export var jar_empty_texture: Texture2D
@export var kettle_cold_texture: Texture2D
@export var kettle_hot_texture: Texture2D
## Vier Dampfbilder nebeneinander (je 16 × 24 Pixel).
@export var steam_sheet: Texture2D

var _jar_buttons: Dictionary[TeaData, TextureButton] = {}
var _jar_labels: Dictionary[TeaData, Label] = {}
var _temperature_buttons: Dictionary[int, Button] = {}
var _temperature_group := ButtonGroup.new()
## Der Wasserkocher wurde angeklickt; der nächste Klick auf die Tasse gießt ein.
var _kettle_picked_up: bool = false
var _steam_frames: Array[AtlasTexture] = []
var _steam_time: float = 0.0

@onready var title_label: Label = %Title
@onready var step_hint: Label = %StepHint
@onready var shelf: HBoxContainer = %Shelf
@onready var strainer_button: TextureButton = %StrainerButton
@onready var cup_button: TextureButton = %CupButton
@onready var tea_in_cup: TextureRect = %TeaInCup
@onready var strainer_in_cup: TextureRect = %StrainerInCup
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var steam: TextureRect = %Steam
@onready var kettle_button: TextureButton = %KettleButton
@onready var temperature_buttons_row: HBoxContainer = %TemperatureButtons
@onready var temperature_note: Label = %TemperatureNote
@onready var timer_button: TextureButton = %TimerButton
@onready var timer_label: Label = %TimerLabel
@onready var reset_button: Button = %ResetButton
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	assert(station != null, "Nahansicht: keine Teestation zugewiesen")
	visible = false
	_build_jars()
	_build_temperature_buttons()
	_build_steam_frames()
	strainer_button.pressed.connect(_on_strainer_pressed)
	cup_button.pressed.connect(_on_cup_pressed)
	kettle_button.pressed.connect(_on_kettle_pressed)
	timer_button.pressed.connect(_on_timer_pressed)
	reset_button.pressed.connect(station.reset_brewing)
	close_button.pressed.connect(close_window)
	station.brewing_changed.connect(_refresh)
	Inventory.item_changed.connect(_on_item_changed)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(INTERACT_ACTION):
		close_window()
		get_viewport().set_input_as_handled()
		return
	super(event)


func _process(delta: float) -> void:
	if not visible:
		return
	_update_progress()
	_animate_steam(delta)


func _on_window_opening() -> void:
	_kettle_picked_up = false
	_refresh()


func _on_window_closing() -> void:
	_kettle_picked_up = false


# --- Aufbau ---

func _build_jars() -> void:
	for tea in station.teas:
		var jar_slot := VBoxContainer.new()
		shelf.add_child(jar_slot)

		var jar_button := TextureButton.new()
		jar_button.custom_minimum_size = JAR_SIZE
		jar_button.ignore_texture_size = true
		jar_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		jar_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		jar_button.tooltip_text = tea.display_name
		jar_button.pressed.connect(_on_jar_pressed.bind(tea))
		jar_slot.add_child(jar_button)

		var jar_label := Label.new()
		jar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		jar_slot.add_child(jar_label)

		_jar_buttons[tea] = jar_button
		_jar_labels[tea] = jar_label


func _build_temperature_buttons() -> void:
	for degrees in station.temperatures:
		var button := Button.new()
		button.text = "%d °C" % degrees
		button.toggle_mode = true
		button.button_group = _temperature_group
		temperature_buttons_row.add_child(button)
		_temperature_buttons[degrees] = button


func _build_steam_frames() -> void:
	for frame in STEAM_FRAME_COUNT:
		var steam_frame := AtlasTexture.new()
		steam_frame.atlas = steam_sheet
		steam_frame.region = Rect2(Vector2(frame * STEAM_FRAME_SIZE.x, 0.0), STEAM_FRAME_SIZE)
		_steam_frames.append(steam_frame)
	steam.texture = _steam_frames[0]


# --- Klicks ---

func _on_jar_pressed(tea: TeaData) -> void:
	if station.state != TeaStation.BrewState.EMPTY:
		return
	if not station.fill_strainer(tea):
		step_hint.text = "Keine %s im Vorrat – ernte sie im Beet." % tea.herb.display_name


func _on_strainer_pressed() -> void:
	station.insert_strainer()


func _on_kettle_pressed() -> void:
	match station.state:
		TeaStation.BrewState.STRAINER_IN_CUP:
			station.start_heating(_selected_temperature())
		TeaStation.BrewState.WATER_HOT:
			_kettle_picked_up = not _kettle_picked_up
			_refresh()


func _on_cup_pressed() -> void:
	match station.state:
		TeaStation.BrewState.WATER_HOT:
			if _kettle_picked_up:
				_kettle_picked_up = false
				station.pour_water()
			else:
				step_hint.text = "Nimm zuerst den Wasserkocher."
		TeaStation.BrewState.STEEPING:
			step_hint.text = "%s zieht noch – etwa %d Sekunden." % [station.tea.display_name, ceili(station.remaining)]
		TeaStation.BrewState.STEEPED:
			station.remove_strainer()
		TeaStation.BrewState.CUP_READY:
			station.collect_tea()


func _on_timer_pressed() -> void:
	station.set_timer_enabled(not station.timer_enabled)


func _on_item_changed(_id: String, _amount: int) -> void:
	_refresh_jars()


func _selected_temperature() -> int:
	var pressed_button: BaseButton = _temperature_group.get_pressed_button()
	for degrees in _temperature_buttons:
		if _temperature_buttons[degrees] == pressed_button:
			return degrees
	return station.tea.recommended_temperature


# --- Anzeige ---

func _refresh() -> void:
	if station.state != TeaStation.BrewState.WATER_HOT:
		_kettle_picked_up = false
	_refresh_title()
	_refresh_jars()
	_refresh_strainer()
	_refresh_cup()
	_refresh_kettle()
	_refresh_temperatures()
	_refresh_timer()
	_refresh_step_hint()
	reset_button.disabled = not station.can_reset()
	_update_progress()


func _refresh_title() -> void:
	if station.state == TeaStation.BrewState.EMPTY:
		title_label.text = "Teestation"
	else:
		title_label.text = "Teestation – %s" % station.tea.display_name


func _refresh_jars() -> void:
	var choosing_herbs: bool = station.state == TeaStation.BrewState.EMPTY
	for tea in _jar_buttons:
		var has_herbs: bool = station.has_herbs_for(tea)
		var jar_button: TextureButton = _jar_buttons[tea]
		jar_button.texture_normal = tea.herb.jar_texture if has_herbs else jar_empty_texture
		jar_button.disabled = not choosing_herbs
		_set_active_look(jar_button, choosing_herbs and has_herbs)
		_jar_labels[tea].text = "%s (%d)" % [tea.herb.display_name, Inventory.get_count(tea.herb.id)]


func _refresh_strainer() -> void:
	var state: TeaStation.BrewState = station.state
	var strainer_is_in_cup: bool = state in [
		TeaStation.BrewState.STRAINER_IN_CUP,
		TeaStation.BrewState.HEATING,
		TeaStation.BrewState.WATER_HOT,
		TeaStation.BrewState.STEEPING,
		TeaStation.BrewState.STEEPED,
	]
	if state == TeaStation.BrewState.HERBS_IN_STRAINER:
		strainer_button.texture_normal = station.tea.herb.strainer_texture
	else:
		strainer_button.texture_normal = strainer_empty_texture
	strainer_button.disabled = state != TeaStation.BrewState.HERBS_IN_STRAINER
	_set_active_look(strainer_button, state == TeaStation.BrewState.HERBS_IN_STRAINER)
	# Steckt das Sieb in der Tasse, bleibt sein Platz leer, damit nichts verrutscht.
	if strainer_is_in_cup:
		strainer_button.modulate.a = 0.0


func _refresh_cup() -> void:
	var state: TeaStation.BrewState = station.state
	var tea: TeaData = station.tea
	strainer_in_cup.visible = state in [TeaStation.BrewState.STRAINER_IN_CUP, TeaStation.BrewState.HEATING, TeaStation.BrewState.WATER_HOT]
	strainer_in_cup.texture = tea.herb.strainer_texture
	tea_in_cup.visible = state == TeaStation.BrewState.STEEPING or state == TeaStation.BrewState.STEEPED
	tea_in_cup.texture = tea.steeping_cup_texture

	match state:
		TeaStation.BrewState.STEEPING, TeaStation.BrewState.STEEPED:
			cup_button.texture_normal = cup_water_texture
		TeaStation.BrewState.CUP_READY:
			cup_button.texture_normal = tea.cup_texture
		_:
			cup_button.texture_normal = cup_empty_texture

	var cup_can_be_used: bool = (state == TeaStation.BrewState.WATER_HOT and _kettle_picked_up) \
		or state == TeaStation.BrewState.STEEPED or state == TeaStation.BrewState.CUP_READY
	_set_active_look(cup_button, cup_can_be_used or state == TeaStation.BrewState.STEEPING)


func _refresh_kettle() -> void:
	var state: TeaStation.BrewState = station.state
	kettle_button.texture_normal = kettle_hot_texture if state == TeaStation.BrewState.WATER_HOT else kettle_cold_texture
	_set_active_look(kettle_button, state == TeaStation.BrewState.STRAINER_IN_CUP or state == TeaStation.BrewState.WATER_HOT)
	if _kettle_picked_up:
		kettle_button.modulate = PICKED_UP_KETTLE_COLOR
	var steam_is_rising: bool = state == TeaStation.BrewState.HEATING or state == TeaStation.BrewState.WATER_HOT
	steam.self_modulate.a = 1.0 if steam_is_rising else 0.0


func _refresh_temperatures() -> void:
	var choosing_temperature: bool = station.state == TeaStation.BrewState.STRAINER_IN_CUP
	var shown_temperature: int = station.temperature
	if choosing_temperature and _temperature_group.get_pressed_button() == null:
		shown_temperature = station.tea.recommended_temperature
	for degrees in _temperature_buttons:
		var button: Button = _temperature_buttons[degrees]
		button.disabled = not choosing_temperature
		if not choosing_temperature or shown_temperature == degrees:
			button.set_pressed_no_signal(shown_temperature == degrees)
	if station.state == TeaStation.BrewState.EMPTY:
		temperature_note.text = "Jede Temperatur ergibt einen guten Tee."
	else:
		temperature_note.text = "Empfohlen für %s: %d °C · Jede Temperatur ergibt einen guten Tee." % [
			station.tea.display_name, station.tea.recommended_temperature]


func _refresh_timer() -> void:
	timer_button.modulate.a = 1.0 if station.timer_enabled else INACTIVE_ALPHA
	timer_label.text = "Timer an" if station.timer_enabled else "Timer aus"


func _refresh_step_hint() -> void:
	match station.state:
		TeaStation.BrewState.EMPTY:
			step_hint.text = "Wähle ein Kräuterglas."
		TeaStation.BrewState.HERBS_IN_STRAINER:
			step_hint.text = "Setz das Sieb in die Tasse."
		TeaStation.BrewState.STRAINER_IN_CUP:
			step_hint.text = "Wähle eine Temperatur und schalte den Wasserkocher ein."
		TeaStation.BrewState.HEATING:
			step_hint.text = "Das Wasser wird heiß … Du kannst die Station solange verlassen."
		TeaStation.BrewState.WATER_HOT:
			if _kettle_picked_up:
				step_hint.text = "Klick die Tasse an, um einzugießen."
			else:
				step_hint.text = "Das Wasser ist heiß. Nimm den Wasserkocher."
		TeaStation.BrewState.STEEPING:
			step_hint.text = "%s zieht. Du kannst die Station solange verlassen." % station.tea.display_name
		TeaStation.BrewState.STEEPED:
			step_hint.text = "%s ist fertig. Nimm das Sieb aus der Tasse." % station.tea.display_name
		TeaStation.BrewState.CUP_READY:
			step_hint.text = "Klick die Tasse an, um sie mitzunehmen."


func _update_progress() -> void:
	var state: TeaStation.BrewState = station.state
	var is_timed: bool = state == TeaStation.BrewState.HEATING or state == TeaStation.BrewState.STEEPING
	progress_bar.modulate.a = 1.0 if is_timed else 0.0
	progress_bar.value = station.get_progress()
	if state == TeaStation.BrewState.STEEPING:
		tea_in_cup.modulate.a = lerpf(STEEPING_START_TINT, 1.0, station.get_progress())
	elif state == TeaStation.BrewState.STEEPED:
		tea_in_cup.modulate.a = 1.0


func _animate_steam(delta: float) -> void:
	_steam_time += delta
	var frame: int = int(_steam_time / STEAM_FRAME_DURATION) % STEAM_FRAME_COUNT
	steam.texture = _steam_frames[frame]


func _set_active_look(control: CanvasItem, is_active: bool) -> void:
	control.modulate = Color(1.0, 1.0, 1.0, 1.0 if is_active else INACTIVE_ALPHA)
