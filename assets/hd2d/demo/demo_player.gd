extends Node3D
## Nur für die Demo-Szene: einfache Figur ohne Physik (WASD / Pfeiltasten, E = Aktion).
## In deinem Spiel nimmst du stattdessen deinen CharacterBody3D und hängst
## player_sprite.tscn als Kind an.

@export var speed: float = 3.6
@export var terrain_mask: Texture2D
@export var map_origin: Vector2 = Vector2(-24, -24)
@export var map_size: Vector2 = Vector2(48, 48)

var velocity: Vector3 = Vector3.ZERO
var _mask: Image


func _ready() -> void:
	add_to_group("player")
	if terrain_mask:
		_mask = terrain_mask.get_image()


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): dir.x += 1
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): dir.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): dir.y += 1
	dir = dir.normalized()
	velocity = Vector3(dir.x, 0, dir.y) * speed
	var step := velocity * delta
	if _walkable(position + step):
		position += step
	elif _walkable(position + Vector3(step.x, 0, 0)):
		position.x += step.x
	elif _walkable(position + Vector3(0, 0, step.z)):
		position.z += step.z


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		$PlayerSprite/Sprite.play_action()


func _walkable(p: Vector3) -> bool:
	if absf(p.x - map_origin.x - map_size.x * 0.5) > map_size.x * 0.5 - 1.5:
		return false
	if absf(p.z - map_origin.y - map_size.y * 0.5) > map_size.y * 0.5 - 1.5:
		return false
	if _mask == null:
		return true
	var u := (p.x - map_origin.x) / map_size.x
	var v := (p.z - map_origin.y) / map_size.y
	var px := clampi(int(u * _mask.get_width()), 0, _mask.get_width() - 1)
	var py := clampi(int(v * _mask.get_height()), 0, _mask.get_height() - 1)
	var on_dock := p.x > 1.0 and p.x < 5.9 and absf(p.z + 6.5) < 0.55
	return _mask.get_pixel(px, py).b < 0.42 or on_dock
