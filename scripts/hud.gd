extends CanvasLayer

@onready var mint_label: Label = $"Mint Count"
@onready var mint_tea_label: Label = $"Mint Tea Count"
@onready var money_label: Label = $"Money Count"
@onready var save_label: Label = $"Save Message"

var _save_message_id: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory.item_changed.connect(_on_item_changed)
	Inventory.money_changed.connect(_on_money_changed)
	SaveGame.saved.connect(_on_saved)
	save_label.visible = false
	
	_on_item_changed("mint", Inventory.get_count("mint"))
	_on_item_changed("mint_tea", Inventory.get_count("mint_tea"))
	_on_money_changed(Inventory.money)
	
func _on_item_changed(id: String, amount: int) -> void:
	match id:
		"mint":
			mint_label.text = "Minze: %d" % amount
		"mint_tea":
			mint_tea_label.text = "Minztee: %d" % amount
	
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
	
