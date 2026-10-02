class_name Interactable
extends Area3D

@onready var interaction_label: Label3D = $InteractionLabel

func interact() -> void:
	pass
	
func cycle() -> void:
	pass
	
func set_focused(value: bool) -> void:
	interaction_label.visible = value
	if value:
		update_interaction_label()
		
func update_interaction_label() -> void:
	pass
