@tool
extends Node3D
## Teehütte: Betritt die Figur den Innenraum, werden Dach und Vorderwand
## "weggeschnitten" (sie werfen weiterhin Schatten – der Raum bleibt gemütlich dunkel).
## Die Figur muss in der Gruppe "player" sein.

@export var cutaway: Array[NodePath] = [^"Roof", ^"FrontWall"]
@export var inside_size: Vector3 = Vector3(4.6, 3.0, 3.6) ## Innenraum, lokal um den Ursprung
@export var force_cutaway: bool = false:
	set(v):
		force_cutaway = v
		_set_cut(v)

var _cut: bool = false


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var inside := force_cutaway
	for p in get_tree().get_nodes_in_group("player"):
		if p is Node3D:
			var l: Vector3 = to_local(p.global_position)
			if absf(l.x) < inside_size.x * 0.5 and absf(l.z) < inside_size.z * 0.5 + 0.3 and l.y < inside_size.y:
				inside = true
	if inside != _cut:
		_set_cut(inside)


func _set_cut(v: bool) -> void:
	_cut = v
	if not is_node_ready():
		return
	for p in cutaway:
		var n := get_node_or_null(p)
		if n:
			_apply(n, v)


func _apply(n: Node, v: bool) -> void:
	if n is GeometryInstance3D:
		if not n.has_meta("_orig_cast"):
			n.set_meta("_orig_cast", n.cast_shadow)
		if v:
			n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		else:
			n.cast_shadow = n.get_meta("_orig_cast")
	for c in n.get_children():
		_apply(c, v)
