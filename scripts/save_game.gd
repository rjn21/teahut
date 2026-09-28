extends Node
## Speichert und lädt den Spielstand als JSON-Datei.
## Objekte, die gespeichert werden sollen, sind in der Gruppe "persist"
## und haben die Funktionen get_save_data() und load_save_data(data).

signal saved(ok: bool)

const SAVE_PATH := "user://savegame.json"
const TEMP_PATH := "user://savegame.tmp"
const BACKUP_PATH := "user://savegame.bak"
const SAVE_VERSION := 1
const PERSIST_GROUP := "persist"


func _notification(what: int) -> void:
	# Fenster wird über X oder Alt+F4 geschlossen
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BACKUP_PATH)


func save_game() -> bool:
	var data := {
		"version": SAVE_VERSION,
		"Inventory": Inventory.to_dict(),
		"nodes": _collect_node_data(),
	}

	if not _write_json(TEMP_PATH, data):
		saved.emit(false)
		return false
	# Bisherigen Stand als Sicherung behalten, dann die neue Datei an seine Stelle setzen.
	# Nur ein lesbarer Stand wird zur Sicherung, sonst würde eine kaputte Datei die gute Sicherung überschreiben.
	if not _read_json(SAVE_PATH, false).is_empty():
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.remove_absolute(BACKUP_PATH)
		DirAccess.rename_absolute(SAVE_PATH, BACKUP_PATH)
	elif FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var err := DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)
	if err != OK:
		push_error("Speichern fehlgeschlagen: " + error_string(err))
		saved.emit(false)
		return false

	print("Spiel gespeichert: ", ProjectSettings.globalize_path(SAVE_PATH))
	saved.emit(true)
	return true


func load_game() -> bool:
	var data := _read_json(SAVE_PATH)
	if data.is_empty():
		data = _read_json(BACKUP_PATH)
		if data.is_empty():
			return false
		push_warning("Spielstand fehlt oder ist beschädigt – die Sicherung wird geladen.")

	Inventory.from_dict(data.get("Inventory", {}))
	_apply_node_data(data.get("nodes", {}))
	print("Spielstand geladen")
	return true


func delete_save() -> void:
	for path in [SAVE_PATH, BACKUP_PATH, TEMP_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


# Sammelt die Daten aller Nodes in der Gruppe "persist" ein.
func _collect_node_data() -> Dictionary:
	var result := {}
	for node in get_tree().get_nodes_in_group(PERSIST_GROUP):
		result[_key_for(node)] = node.call("get_save_data")
	return result


# Gibt jedem Node in der Gruppe "persist" seine gespeicherten Daten zurück.
func _apply_node_data(nodes_data: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group(PERSIST_GROUP):
		var key := _key_for(node)
		if nodes_data.has(key):
			node.call("load_save_data", nodes_data[key])
		else:
			push_warning("Kein gespeicherter Eintrag für " + key)


# Eindeutiger Name eines Nodes: sein Pfad ab der Welt-Szene, z. B. "HerbPlot".
func _key_for(node: Node) -> String:
	return str(get_tree().current_scene.get_path_to(node))


# Schreibt ein Dictionary als lesbares JSON. Gibt false zurück, wenn es nicht klappt.
func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Speichern fehlgeschlagen: " + error_string(FileAccess.get_open_error()))
		return false
	var ok := file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return ok


# Liest eine JSON-Datei. Gibt {} zurück, wenn sie fehlt oder beschädigt ist.
# warn = false: ohne Warnung, nur zum Prüfen.
func _read_json(path: String, warn: bool = true) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		if warn:
			push_warning("Datei ist beschädigt und wird ignoriert: %s" % ProjectSettings.globalize_path(path))
		return {}
	return json.data
