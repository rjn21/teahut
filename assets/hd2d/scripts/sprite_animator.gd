@tool
extends AnimatedSprite3D
## Wählt die passende Animation (idle/walk/act × down/left/right/up) automatisch
## aus der Bewegung des Eltern-Knotens. Funktioniert mit jedem Knoten, der eine
## Eigenschaft `velocity` hat – also z. B. direkt mit deinem CharacterBody3D.
##
## Die Richtungen beziehen sich auf die Welt: -Z = oben/hinten, +X = rechts.
## Passt, solange deine Kamera wie in HD-2D fest nach -Z schaut.

@export var body: Node3D ## Leer lassen = Eltern-Knoten verwenden.
@export var walk_threshold: float = 0.15
@export var walk_fps_at_speed: float = 4.0 ## Bei dieser Geschwindigkeit läuft die Animation mit Normaltempo.

var facing: String = "down"
var _act_time: float = 0.0


func _ready() -> void:
	if not Engine.is_editor_hint():
		play("idle_down")


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var b: Node = body if body else get_parent()
	var v: Vector3 = Vector3.ZERO
	if b and b.get("velocity") != null:
		v = b.get("velocity")
	var flat := Vector2(v.x, v.z)

	if _act_time > 0.0:
		_act_time -= delta
		return

	if flat.length() > walk_threshold:
		if absf(flat.x) > absf(flat.y) * 1.1:
			facing = "right" if flat.x > 0.0 else "left"
		else:
			facing = "down" if flat.y > 0.0 else "up"
		_play("walk_" + facing)
		speed_scale = clampf(flat.length() / walk_fps_at_speed, 0.6, 1.8)
	else:
		_play("idle_" + facing)
		speed_scale = 1.0


## Kurze Arbeits-Pose (pflanzen, ernten, Tee abgeben …).
func play_action(duration: float = 0.45) -> void:
	_act_time = duration
	_play("act_" + facing)


## Blickrichtung von außen setzen, z. B. zum Beet drehen: "down", "left", "right", "up".
func face(dir: String) -> void:
	facing = dir


func _play(anim_name: String) -> void:
	if animation != anim_name:
		play(anim_name)
