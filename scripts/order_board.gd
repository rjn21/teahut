class_name OrderBoard
extends Interactable
## Bestellbrett: bietet je eine Bestellung pro Teesorte an.
## Q blättert durch die Angebote, E nimmt das angezeigte als aktive Bestellung an.
## Eine Bestellung verlangt genau eine Tasse dieser Sorte und zahlt deren Preis aus.
## Abgegeben wird an der Ablage; danach ist keine Bestellung mehr aktiv.

signal active_order_changed(order: TeaData)

@export var teas: Array[TeaData] = []

var displayed_index: int = 0
var displayed_order: TeaData:
	get:
		return teas[displayed_index]

## null = keine Bestellung angenommen.
var active_order: TeaData = null


func _ready() -> void:
	assert(not teas.is_empty(), "Bestellbrett: keine TeaData zugewiesen")
	add_to_group("persist")
	interaction_label.visible = false
	update_interaction_label()


func interact() -> void:
	accept_displayed_order()


func cycle() -> void:
	show_next_order()


func has_active_order() -> bool:
	return active_order != null


func accept_displayed_order() -> void:
	if active_order == displayed_order:
		return
	_set_active_order(displayed_order)


func show_next_order() -> void:
	displayed_index = (displayed_index + 1) % teas.size()
	update_interaction_label()


## Wird von der Ablage aufgerufen, sobald die Bestellung ausgezahlt ist.
func complete_active_order() -> void:
	_set_active_order(null)


func update_interaction_label() -> void:
	var offer: String = "%s · %d Münzen" % [displayed_order.display_name, displayed_order.price]
	if displayed_order == active_order:
		interaction_label.text = "%s (aktiv) · Q - nächste Bestellung" % offer
	else:
		interaction_label.text = "%s · E - annehmen · Q - nächste Bestellung" % offer


func _set_active_order(order: TeaData) -> void:
	active_order = order
	update_interaction_label()
	active_order_changed.emit(active_order)


func _find_tea(id: String) -> TeaData:
	for tea in teas:
		if tea.id == id:
			return tea
	return null


#	--- Spielstand ---

func get_save_data() -> Dictionary:
	return {
		"active_order": active_order.id if has_active_order() else "",
		"displayed_order": displayed_order.id,
	}


func load_save_data(data: Dictionary) -> void:
	var displayed_tea := _find_tea(str(data.get("displayed_order", "")))
	displayed_index = maxi(0, teas.find(displayed_tea))
	_set_active_order(_find_tea(str(data.get("active_order", ""))))
