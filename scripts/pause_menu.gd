extends CanvasLayer

@onready var resume_button: Button = $CenterContainer/Buttons/ResumeButton
@onready var save_button: Button = $CenterContainer/Buttons/SaveButton
@onready var quit_button: Button = $CenterContainer/Buttons/QuitButton
@onready var new_game_button: Button = $CenterContainer/Buttons/NewGameButton
@onready var confirm_new_game: ConfirmationDialog = $ConfirmNewGame


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	resume_button.pressed.connect(close_menu)
	save_button.pressed.connect(_on_save_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	confirm_new_game.confirmed.connect(_on_new_game_confirmed)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()
		
func open_menu() -> void:
	visible = true
	get_tree().paused = true
	resume_button.grab_focus()
	
func close_menu() -> void:
	confirm_new_game.hide()
	visible = false
	get_tree().paused = false
	
func _on_save_pressed() -> void:
	SaveGame.save_game()
	
func _on_quit_pressed() -> void:
	if SaveGame.save_game():
		get_tree().quit()
		
func _on_new_game_pressed() -> void:
	confirm_new_game.popup_centered()
	
func _on_new_game_confirmed() -> void:
	SaveGame.delete_save()
	Inventory.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
