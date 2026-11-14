extends Node3D
## Hauptszene. Lädt beim Start den Spielstand und verbindet Fenster mit der Figur.

@onready var player: Player = $Player
@onready var decoration_catalog: DecorationCatalog = $DecorationCatalog


func _ready() -> void:
	decoration_catalog.opened.connect(_on_window_opened)
	decoration_catalog.closed.connect(_on_window_closed)
	SaveGame.load_game()


func _on_window_opened() -> void:
	player.input_enabled = false


func _on_window_closed() -> void:
	player.input_enabled = true
