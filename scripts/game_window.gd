class_name GameWindow
extends CanvasLayer
## Grundlage für Fenster über der Spielwelt (Einrichtungskatalog, Nahansicht der Teestation).
## world.gd hört auf opened/closed: Solange ein Fenster offen ist, steht die Figur still,
## und es ist immer höchstens ein Fenster offen. Escape schließt das offene Fenster.
## Fenster stehen in world.tscn nach dem PauseMenu, damit sie Escape vorher bekommen.

signal opened
signal closed

const CLOSE_ACTION := "pause"


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(CLOSE_ACTION):
		close_window()
		get_viewport().set_input_as_handled()


func open_window() -> void:
	if visible:
		return
	_on_window_opening()
	visible = true
	opened.emit()


func close_window() -> void:
	if not visible:
		return
	_on_window_closing()
	visible = false
	closed.emit()


## Für abgeleitete Fenster: Inhalt vor dem Öffnen auffrischen.
func _on_window_opening() -> void:
	pass


## Für abgeleitete Fenster: offene Dialoge und Zwischenzustände aufräumen.
func _on_window_closing() -> void:
	pass
