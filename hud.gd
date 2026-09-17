extends CanvasLayer

@onready var mint_label: Label = $"Mint Count"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory.mint_changed.connect(_on_mint_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_mint_changed(amount: int) -> void:
	mint_label.text = "Minze: %d" % amount
