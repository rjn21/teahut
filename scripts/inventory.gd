extends Node

signal item_changed(id: String, amount: int)
signal money_changed(amount: int)

var items: Dictionary[String, int] = {}
var money: int = 0

func get_count(id: String) -> int:
	return items.get(id, 0)
	
func add_item(id: String, amount: int) -> void:
	if amount <= 0:
		return
	_set_count(id, get_count(id) + amount)
	
func try_take_item(id: String, amount: int) -> bool:
	if amount <= 0 or get_count(id) < amount:
		return false
	_set_count(id, get_count(id) - amount)
	return true

func add_money(amount: int) -> void:
	if amount <= 0:
		return
	money += amount
	money_changed.emit(money)

func try_spend_money(amount: int) -> bool:
	if amount <= 0 or money < amount:
		return false
	money -= amount
	money_changed.emit(money)
	return true
	
func reset() -> void:
	for id in items.keys():
		items[id] = 0
	money = 0
	_emit_all()

func to_dict() -> Dictionary:
	return {
		"money": money,
		"items": items.duplicate()
	}

func from_dict(data: Dictionary) -> void:
	for id in items.keys():
		items[id] = 0
	var saved_items: Dictionary = data.get("items", {})
	for id in saved_items:
		items[str(id)] = maxi(0, int(saved_items[id]))
	money = maxi(0, int(data.get("money", 0)))
	_emit_all()
	
func _set_count(id: String, amount: int) -> void:
	items[id] = amount
	item_changed.emit(id, amount)

func _emit_all() -> void:
	for id in items:
		item_changed.emit(id, items[id])
	money_changed.emit(money)
		
