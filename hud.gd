extends CanvasLayer

@onready var mint_label: Label = $"Mint Count"
@onready var mint_tea_label: Label = $"Mint Tea Count"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory.mint_changed.connect(_on_mint_changed)
	Inventory.mint_tea_changed.connect(_on_mint_tea_changed)
	
	_on_mint_changed(Inventory.mint)
	_on_mint_tea_changed(Inventory.mint_tea)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_mint_changed(amount: int) -> void:
	mint_label.text = "Minze: %d" % amount
	

func _on_mint_tea_changed(amount: int) -> void:
	mint_tea_label.text = "Mintzee: %d" % amount
