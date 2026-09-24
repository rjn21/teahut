extends Area3D

@export var payout: int = 10

var player_in_range: bool = false

@onready var interaction_label: Label3D = $InteractionLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		deliver_tea()
	
func deliver_tea() -> void:
	if not Inventory.try_take_mint_tea(1):
		interaction_label.text = "Kein Minztee dabei"
		return
	
	Inventory.add_money(payout)
	update_interaction_label()
	
func update_interaction_label() -> void:
	interaction_label.text = "E - Minztee abgeben (+%d Münzen)" % payout
