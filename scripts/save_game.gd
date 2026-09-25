extends Node


signal  saved(ok: bool)

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1
const PERSIST_GROUP := "persist"

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
	
func save_game() -> bool:
	var data := {
		"version": SAVE_VERSION,
		"Inventory": Inventory.to_dict(),
		"nodes": _collect_node_data()
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Speichern fehlgeschlagen: " + error_string(FileAccess.get_open_error()))
		saved.emit(false)
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("Spiel gespeichert: ", ProjectSettings.globalize_path(SAVE_PATH))
	saved.emit(true)
	return true
	
func load_game() -> bool:
	if not has_save():
		return false
	
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var data: Variant = JSON.parse_string(text)
	if not data is Dictionary:
		push_warning("Spielstand ist beschädigt und wird ignoriert " + ProjectSettings.globalize_path(SAVE_PATH))
		return false
	
	Inventory.from_dict(data.get("Inventory", {}))
	_apply_node_data(data.get("nodes", {}))
	print("Spielstand geladen")
	return true
	
func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		
func _collect_node_data() -> Dictionary:
	var result := {}
	for node in get_tree().get_nodes_in_group(PERSIST_GROUP):
		result[_key_for(node)] = node.call("get_save_data")
	return result
	
func _apply_node_data(nodes_data: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group(PERSIST_GROUP):
		var key := _key_for(node)
		if nodes_data.has(key):
			node.call("load_save_data", nodes_data[key])
		else:
			push_warning("Kein gespeicherter Eintrag für " + key)

func _key_for(node: Node) -> String:
	return str(get_tree().current_scene.get_path_to(node))

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
