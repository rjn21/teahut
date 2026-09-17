extends Node

signal  mint_changed(amount: int)

var mint: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func add_mint(amount: int) -> void:
	mint += amount
	mint_changed.emit(mint)
	print("Minze im Inventar: ", mint)
