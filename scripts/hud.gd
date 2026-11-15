extends CanvasLayer

const SAVE_MESSAGE_DURATION := 2.0
const TIMER_MESSAGE_DURATION := 5.0

@export var herbs: Array[HerbData] = []
@export var teas: Array[TeaData] = []
@export var order_board: OrderBoard
@export var tea_station: TeaStation

var _item_labels: Dictionary[String, Label] = {}
var _item_names: Dictionary[String, String] = {}
## Zählt Meldungen hoch, damit eine ältere Meldung eine neuere nicht vorzeitig ausblendet.
var _message_id: int = 0

@onready var stats: VBoxContainer = $Stats
@onready var money_label: Label = $"Stats/Money Count"
@onready var active_order_label: Label = $"Stats/Active Order"
@onready var message_label: Label = $Message


func _ready() -> void:
	order_board.active_order_changed.connect(_on_active_order_changed)
	_on_active_order_changed(order_board.active_order)

	for herb in herbs:
		_add_item_row(herb.id, herb.display_name)
	for tea in teas:
		_add_item_row(tea.id, tea.display_name)

	Inventory.item_changed.connect(_on_item_changed)
	Inventory.money_changed.connect(_on_money_changed)
	SaveGame.saved.connect(_on_saved)
	tea_station.timer_rang.connect(_on_tea_station_timer_rang)
	message_label.visible = false
	_on_money_changed(Inventory.money)

func _add_item_row(id: String, display_name: String) -> void:
	var label := Label.new()
	stats.add_child(label)
	_item_labels[id] = label
	_item_names[id] = display_name
	_on_item_changed(id, Inventory.get_count(id))

func _on_item_changed(id: String, amount: int) -> void:
	if not _item_labels.has(id):
		return
	_item_labels[id].text = "%s: %d" % [_item_names[id], amount]

func _on_money_changed(amount: int) -> void:
	money_label.text = "Münzen: %d" % amount

func _on_active_order_changed(order: TeaData) -> void:
	if order == null:
		active_order_label.text = "Keine Bestellung"
	else:
		active_order_label.text = "Bestellung: %s (+%d)" % [order.display_name, order.price]

func _on_saved(ok: bool) -> void:
	_show_message("Spiel gespeichert" if ok else "Speichern fehlgeschlagen", SAVE_MESSAGE_DURATION)


func _on_tea_station_timer_rang(tea: TeaData) -> void:
	_show_message("Der Timer klingelt: %s ist fertig. Nimm das Sieb heraus." % tea.display_name, TIMER_MESSAGE_DURATION)


func _show_message(text: String, duration: float) -> void:
	message_label.text = text
	message_label.visible = true
	_message_id += 1
	var my_id := _message_id
	await get_tree().create_timer(duration).timeout
	if my_id == _message_id:
		message_label.visible = false
