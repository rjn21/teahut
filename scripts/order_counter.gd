extends Interactable
## Ablage: Hier wird die aktive Bestellung vom Bestellbrett abgegeben.
## E stellt eine passende Tasse ab, ein zweites E gibt die Bestellung ab, Q nimmt die Tasse zurück.
## Die abgestellte Tasse ist nur vorgemerkt und bleibt bis zur Abgabe im Inventar.
## So kann beim Speichern, Beenden oder Wechseln der Bestellung keine Tasse verloren gehen.

enum CounterState {
	EMPTY,
	CUP_PLACED,
}

@export var order_board: OrderBoard

var state: CounterState = CounterState.EMPTY

@onready var placed_cup: Sprite3D = %PlacedCup


func _ready() -> void:
	assert(order_board != null, "Ablage: kein Bestellbrett zugewiesen")
	interaction_label.visible = false
	order_board.active_order_changed.connect(_on_active_order_changed)
	_clear_tray()


func interact() -> void:
	match state:
		CounterState.EMPTY:
			place_cup()
		CounterState.CUP_PLACED:
			deliver_order()


func cycle() -> void:
	if state == CounterState.CUP_PLACED:
		take_cup_back()


func place_cup() -> void:
	var order: TeaData = order_board.active_order
	if order == null:
		interaction_label.text = "Erst am Bestellbrett eine Bestellung annehmen"
		return
	if Inventory.get_count(order.id) < 1:
		interaction_label.text = "Kein %s dabei" % order.display_name
		return

	state = CounterState.CUP_PLACED
	placed_cup.texture = order.cup_texture
	placed_cup.visible = true
	update_interaction_label()


func take_cup_back() -> void:
	_clear_tray()
	update_interaction_label()


func deliver_order() -> void:
	if state != CounterState.CUP_PLACED:
		return

	var order: TeaData = order_board.active_order
	if order == null or not Inventory.try_take_item(order.id, 1):
		take_cup_back()
		return

	_clear_tray()
	Inventory.add_money(order.price)
	order_board.complete_active_order()
	SaveGame.save_game()
	interaction_label.text = "%s abgegeben (+%d Münzen)" % [order.display_name, order.price]


func update_interaction_label() -> void:
	var order: TeaData = order_board.active_order
	if order == null:
		interaction_label.text = "Keine Bestellung · zum Bestellbrett"
		return

	match state:
		CounterState.EMPTY:
			interaction_label.text = "E - %s abstellen" % order.display_name
		CounterState.CUP_PLACED:
			interaction_label.text = "E - Bestellung abgeben (+%d Münzen) · Q - zurücknehmen" % order.price


func _clear_tray() -> void:
	state = CounterState.EMPTY
	placed_cup.visible = false


## Eine abgestellte Tasse gehört zur bisherigen Bestellung und wird zurückgenommen.
func _on_active_order_changed(_order: TeaData) -> void:
	if state == CounterState.CUP_PLACED:
		take_cup_back()
