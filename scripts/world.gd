extends Node3D
## Hauptszene. Lädt beim Start den Spielstand und verbindet die Fenster mit der Figur:
## Solange ein Fenster offen ist, steht die Figur still, und es ist immer höchstens eines offen.

@onready var player: Player = $Player
@onready var tea_station: TeaStation = $TeaStation
@onready var decoration_catalog: DecorationCatalog = $DecorationCatalog
@onready var tea_station_close_up: TeaStationCloseUp = $TeaStationCloseUp

var _open_window: GameWindow = null


func _ready() -> void:
	for window: GameWindow in [decoration_catalog, tea_station_close_up]:
		window.opened.connect(_on_window_opened.bind(window))
		window.closed.connect(_on_window_closed.bind(window))
	tea_station.close_up_requested.connect(tea_station_close_up.open_window)
	SaveGame.load_game()


func _on_window_opened(window: GameWindow) -> void:
	var previous_window: GameWindow = _open_window
	_open_window = window
	if previous_window != null and previous_window != window:
		previous_window.close_window()
	player.input_enabled = false


func _on_window_closed(window: GameWindow) -> void:
	if window != _open_window:
		return
	_open_window = null
	# Erst am Ende des Bilds freigeben: Sonst löst dieselbe Taste (E schließt die Nahansicht)
	# sofort wieder eine Interaktion der Figur aus.
	player.set_deferred("input_enabled", true)
