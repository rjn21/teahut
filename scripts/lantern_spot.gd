extends Interactable

@export var price: int = 10

@onready var lantern: NightGlow = $Lantern
@onready var lantern_sprite: Sprite3D = $Lantern/Sprite

var bought: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("persist")
	interaction_label.visible = false
	show_as_preview(true)
	update_interaction_label()

# Called every frame. 'delta' is the elapsed time since the previous frame.	
func buy_lantern() -> void:
	if bought:
		return
	if not Inventory.try_spend_money(price):
		interaction_label.text = "Nicht genug Münzen (%d nötig)" % price
		return
	bought = true
	show_as_preview(false)
	update_interaction_label()
	SaveGame.save_game()
	
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
	
func interact() -> void:
	buy_lantern()
	
#	--- Spielstand ---
func get_save_data() -> Dictionary:
	return {
		"bought": bought
	}

func load_save_data(data: Dictionary) -> void:
	bought = bool(data.get("bought", false))
	show_as_preview(not bought)
	update_interaction_label()
		
