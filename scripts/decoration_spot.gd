class_name DecorationSpot
extends Node3D
## Fester Platz für eine kaufbare Dekoration (Spec 9).
## Bis zum Kauf ist sie unsichtbar. Gekauft lässt sie sich ein- und ausblenden,
## ohne verloren zu gehen. Gekauft wird über den Einrichtungskatalog.
## Die Grafik ist der Kind-Node mit dem eindeutigen Namen %Graphic.

signal state_changed

@export var decoration: DecorationData

var owned: bool = false
var shown: bool = true

@onready var graphic: Node3D = %Graphic


func _ready() -> void:
	assert(decoration != null, "Dekorationsplatz %s: keine DecorationData zugewiesen" % name)
	add_to_group("persist")
	_update_graphic()


func is_visible_in_world() -> bool:
	return owned and shown


## Zieht den Preis einmal ab und stellt die Dekoration auf. false, wenn schon gekauft
## oder das Geld nicht reicht – dann ändert sich nichts.
func try_buy() -> bool:
	if owned:
		return false
	if not Inventory.try_spend_money(decoration.price):
		return false
	owned = true
	shown = true
	_update_graphic()
	state_changed.emit()
	return true


func set_shown(value: bool) -> void:
	if not owned or shown == value:
		return
	shown = value
	_update_graphic()
	state_changed.emit()


func _update_graphic() -> void:
	graphic.visible = is_visible_in_world()
	if graphic is NightGlow:
		(graphic as NightGlow).lit = graphic.visible


#	--- Spielstand ---

func get_save_data() -> Dictionary:
	return {
		"owned": owned,
		"shown": shown,
	}


func load_save_data(data: Dictionary) -> void:
	# "bought" stammt aus Spielständen vor M6e, als nur die Laterne kaufbar war.
	owned = bool(data.get("owned", data.get("bought", false)))
	shown = bool(data.get("shown", true))
	_update_graphic()
	state_changed.emit()
