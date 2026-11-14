class_name DecorationCatalog
extends CanvasLayer
## Einrichtungskatalog (Spec 9): Taste C öffnet und schließt, Escape schließt.
## Zeigt alle Dekorationsplätze mit Preis und Status; Kauf mit Bestätigung,
## gekaufte Dekorationen lassen sich ein- und ausblenden.
## Die Simulation läuft weiter; die Welt sperrt nur die Figur, solange der Katalog offen ist.

signal opened
signal closed

const CATALOG_ACTION := "catalog"
const CLOSE_ACTION := "pause"

@export var spots: Array[DecorationSpot] = []

var _rows: Array[DecorationCatalogRow] = []
## Die Dekoration, deren Kauf gerade im Bestätigungsdialog steht.
var _pending_purchase: DecorationSpot = null

@onready var rows_container: VBoxContainer = %Rows
@onready var close_button: Button = %CloseButton
@onready var confirm_purchase: ConfirmationDialog = %ConfirmPurchase


func _ready() -> void:
	visible = false
	for spot in spots:
		_add_row(spot)
		spot.state_changed.connect(_refresh_rows)
	Inventory.money_changed.connect(_on_money_changed)
	close_button.pressed.connect(close_catalog)
	confirm_purchase.confirmed.connect(_on_purchase_confirmed)
	confirm_purchase.canceled.connect(_on_purchase_canceled)
	_refresh_rows()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(CATALOG_ACTION):
		if visible:
			close_catalog()
		else:
			open_catalog()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed(CLOSE_ACTION):
		close_catalog()
		get_viewport().set_input_as_handled()


func open_catalog() -> void:
	_refresh_rows()
	visible = true
	opened.emit()


func close_catalog() -> void:
	confirm_purchase.hide()
	_pending_purchase = null
	visible = false
	closed.emit()


func _add_row(spot: DecorationSpot) -> void:
	var row := DecorationCatalogRow.new()
	rows_container.add_child(row)
	row.setup(spot)
	row.buy_requested.connect(_on_buy_requested)
	row.visibility_toggle_requested.connect(_on_visibility_toggle_requested)
	_rows.append(row)


func _refresh_rows() -> void:
	for row in _rows:
		row.refresh(Inventory.money)


func _on_money_changed(_amount: int) -> void:
	_refresh_rows()


func _on_buy_requested(spot: DecorationSpot) -> void:
	_pending_purchase = spot
	confirm_purchase.dialog_text = "%s für %d Münzen kaufen?" % [spot.decoration.display_name, spot.decoration.price]
	confirm_purchase.popup_centered()


func _on_purchase_confirmed() -> void:
	var spot: DecorationSpot = _pending_purchase
	_pending_purchase = null
	if spot != null and spot.try_buy():
		SaveGame.save_game()


func _on_purchase_canceled() -> void:
	_pending_purchase = null


func _on_visibility_toggle_requested(spot: DecorationSpot) -> void:
	spot.set_shown(not spot.shown)
	SaveGame.save_game()
