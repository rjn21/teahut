extends Interactable

@export var teas: Array[TeaData] = []

func _ready() -> void:
	assert(not teas.is_empty(), "Ablage: keine TeaData zugewiesen")
	interaction_label.visible = false

func deliver_tea() -> void:
	for tea in teas:
		if Inventory.try_take_item(tea.id, 1):
			Inventory.add_money(tea.price)
			SaveGame.save_game()
			interaction_label.text = "%s abgegeben (+%d Münzen)" % [tea.display_name, tea.price]
			return
			
	interaction_label.text = "Kein Tee dabei"

func update_interaction_label() -> void:
	interaction_label.text = "E - Tee abgeben"
	
func interact() -> void:
	deliver_tea()
