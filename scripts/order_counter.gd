extends Area3D

@export var tea: TeaData

var player_in_range: bool = false

@onready var interaction_label: Label3D = $InteractionLabel

func _ready() -> void:
	assert(tea != null, "Ablage: keine TeaData zugewiesen")
	interaction_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true
		update_interaction_label()
		interaction_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
		update_interaction_label()
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		deliver_tea()

func deliver_tea() -> void:
	if not Inventory.try_take_item(tea.id, 1):
		interaction_label.text = "Kein %s dabei" % tea.display_name
		return

	Inventory.add_money(tea.price)
	update_interaction_label()
	SaveGame.save_game()

func update_interaction_label() -> void:
	interaction_label.text = "E - %s abgeben (+%d Münzen)" % [tea.display_name, tea.price]
