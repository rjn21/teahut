extends Area3D

@export var price: int = 10

var player_in_range: bool = false
var bought: bool = false

@onready var interaction_label: Label3D = $InteractionLabel
@onready var lantern: NightGlow = $Lantern
@onready var lantern_sprite: Sprite3D = $Lantern/Sprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_label.visible = false
	show_as_preview(true)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	update_interaction_label()
	
func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true
		update_interaction_label()
		interaction_label.visible = true
		
func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
		interaction_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		buy_lantern()
	
func buy_lantern() -> void:
	if bought:
		return
	if not Inventory.try_spend_money(price):
		interaction_label.text = "Nicht genug Münzen (%d nötig)" % price
		return
	bought = true
	show_as_preview(false)
	update_interaction_label()
	
func update_interaction_label() -> void:
	if bought:
			interaction_label.text = "Laterne gekauft"
	else:
		interaction_label.text = "E - Laterne kaufen (%d Münzen)" % price
		
func show_as_preview(preview: bool) -> void:
	if preview:
		lantern_sprite.modulate = Color(1, 1, 1, 0.35)
		lantern_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		lantern_sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	else:
		lantern_sprite.modulate = Color(1, 1, 1, 1)
		lantern_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		lantern_sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	lantern.lit = not preview
		
