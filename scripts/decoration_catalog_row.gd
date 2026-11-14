class_name DecorationCatalogRow
extends HBoxContainer
## Eine Zeile im Einrichtungskatalog: Vorschaubild, Name, Preis, Status und ein Knopf.
## Die Zeile führt nichts selbst aus, sondern meldet Wünsche per Signal an den Katalog.

signal buy_requested(spot: DecorationSpot)
signal visibility_toggle_requested(spot: DecorationSpot)

const ICON_SIZE := Vector2(48, 48)
const NAME_WIDTH := 170.0
const PRICE_WIDTH := 100.0
const STATUS_WIDTH := 90.0
const BUTTON_WIDTH := 170.0

var spot: DecorationSpot

var _status_label: Label
var _action_button: Button


func setup(decoration_spot: DecorationSpot) -> void:
	spot = decoration_spot
	add_theme_constant_override("separation", 12)

	var icon := TextureRect.new()
	icon.texture = spot.decoration.icon
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(icon)

	add_child(_make_label(spot.decoration.display_name, NAME_WIDTH))
	add_child(_make_label("%d Münzen" % spot.decoration.price, PRICE_WIDTH))

	_status_label = _make_label("", STATUS_WIDTH)
	add_child(_status_label)

	_action_button = Button.new()
	_action_button.custom_minimum_size.x = BUTTON_WIDTH
	_action_button.pressed.connect(_on_action_pressed)
	add_child(_action_button)


## Passt Status und Knopf an den aktuellen Zustand und das Guthaben an.
func refresh(money: int) -> void:
	if spot.owned:
		_status_label.text = "gekauft"
		_action_button.text = "Ausblenden" if spot.shown else "Einblenden"
		_action_button.disabled = false
		return

	_status_label.text = ""
	var missing: int = spot.decoration.price - money
	if missing > 0:
		_action_button.text = "Es fehlen %d Münzen" % missing
		_action_button.disabled = true
	else:
		_action_button.text = "Kaufen"
		_action_button.disabled = false


func _make_label(text: String, width: float) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = width
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _on_action_pressed() -> void:
	if spot.owned:
		visibility_toggle_requested.emit(spot)
	else:
		buy_requested.emit(spot)
