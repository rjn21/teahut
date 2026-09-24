extends CanvasLayer

@onready var mint_label: Label = $"Mint Count"
@onready var mint_tea_label: Label = $"Mint Tea Count"
@onready var money_label: Label = $"Money Count"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory.mint_changed.connect(_on_mint_changed)
	Inventory.mint_tea_changed.connect(_on_mint_tea_changed)
	Inventory.money_changed.connect(_on_money_changed)
	
	
	_on_mint_changed(Inventory.mint)
	_on_mint_tea_changed(Inventory.mint_tea)
	_on_money_changed(Inventory.money)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_mint_changed(amount: int) -> void:
	mint_label.text = "Minze: %d" % amount
	

func _on_mint_tea_changed(amount: int) -> void:
	mint_tea_label.text = "Minztee: %d" % amount
	
func _on_money_changed(amount: int) -> void:
	money_label.text = "Münzen: %d" % amount
	
