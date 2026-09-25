extends Node

signal mint_changed(amount: int)
signal mint_tea_changed(amont: int)
signal money_changed(amount: int)

var mint: int = 0
var mint_tea: int = 0
var money: int = 0

func add_mint(amount: int) -> void:
	if amount <= 0:
		return
	mint += amount
	mint_changed.emit(mint)
	print("Minze im Inventar: ", mint)
	
func add_mint_tea(amount: int) -> void:
	if amount <= 0:
		return	
	mint_tea += amount
	mint_tea_changed.emit(mint_tea)
	print("Minztee im Inventar: ", mint_tea)
	
func add_money(amount: int) -> void:
	if amount <= 0:
		return
	money += amount
	money_changed.emit(money)

func try_take_mint(amount: int) -> bool:
	if amount <= 0 or mint < amount:
		return false
	mint -= amount
	mint_changed.emit(mint)
	return true
	
func try_take_mint_tea(amount: int) -> bool:
	if amount <= 0 or mint_tea < amount:
		return false

	mint_tea -= amount
	mint_tea_changed.emit(mint_tea)
	return true
	
func try_spend_money(amount: int) -> bool:
	if amount <= 0 or money < amount:
		return false
	money -= amount
	money_changed.emit(money)
	return true
	
func reset() -> void:
	mint = 0
	mint_tea = 0
	money = 0
	_emit_all()
	
func to_dict() -> Dictionary:
	return {
		"money": money,
		"items": {
			"mint": mint,
			"mint_tea": mint_tea
		}
	}
	
func from_dict(data: Dictionary) -> void:
	var items: Dictionary = data.get("items", {})
	mint = maxi(0, int(items.get("mint", 0)))
	mint_tea = maxi(0, int(items.get("mint_tea", 0)))
	money = maxi(0, int(data.get("money", 0)))
	_emit_all()
	
func _emit_all() -> void:
	mint_changed.emit(mint)
	mint_tea_changed.emit(mint_tea)
	money_changed.emit(money)

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
	

	

	

	

	

	
