extends CanvasLayer

@export var herbs: Array[HerbData] = []
@export var teas: Array[TeaData] = []


@onready var stats: VBoxContainer = $Stats
@onready var money_label: Label = $"Stats/Money Count"
@onready var save_label: Label = $"Save Message"

var _item_labels: Dictionary[String, Label] = {}
var _item_names: Dictionary[String, String] = {}
var _save_message_id: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for herb in herbs:
		_add_item_row(herb.id, herb.display_name)
	for tea in teas:
		_add_item_row(tea.id, tea.display_name)
	
	Inventory.item_changed.connect(_on_item_changed)
	Inventory.money_changed.connect(_on_money_changed)
	SaveGame.saved.connect(_on_saved)
	save_label.visible = false
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
	
func _on_saved(ok: bool) -> void:
	save_label.text = "Spiel gespeichert" if ok else "Speichern fehlgeschlagen"
	save_label.visible = true
	_save_message_id += 1
	var my_id := _save_message_id
	await get_tree().create_timer(2.0).timeout
	if my_id == _save_message_id:
		save_label.visible = false
	
