extends Node

signal mint_changed(amount: int)
signal mint_tea_changed(amont: int)

var mint: int = 0
var mint_tea: int = 0


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
	
func try_take_mint(amount: int) -> bool:
	if amount <= 0 or mint < amount:
		return false
	
	mint -= amount
	mint_changed.emit(mint)
	return true
	
func add_mint_tea(amount: int) -> void:
	if amount <= 0:
		return
	
	mint_tea += amount
	mint_tea_changed.emit(mint_tea)
	print("Minztee im Inventar: ", mint_tea)
