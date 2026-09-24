@tool
extends Node3D
class_name HerbPlantVisual
## Darstellung eines Beets. Enthält KEINE Spiellogik – dein Beet-Skript setzt nur
## die Werte. Beispiel aus deinem Beet-Skript:
##     $BedVisual.herb = "mint"
##     $BedVisual.set_from_state(state, growth_progress)   # 0.0 … 1.0
##     $BedVisual.wet = is_watered

const HERB_TEXTURES := {
	"mint": preload("res://assets/hd2d/sprites/plants/mint.png"),
	"chamomile": preload("res://assets/hd2d/sprites/plants/chamomile.png"),
	"lavender": preload("res://assets/hd2d/sprites/plants/lavender.png"),
}
const SOIL_DRY := preload("res://assets/hd2d/materials/soil_dry.tres")
const SOIL_WET := preload("res://assets/hd2d/materials/soil_wet.tres")

@export_enum("mint", "chamomile", "lavender") var herb: String = "mint":
	set(v):
		herb = v
		_refresh()
## 0 = frisch gepflanzt, 1 = Keimling, 2 = wachsend, 3 = erntereif
@export_range(0, 3) var stage: int = 3:
	set(v):
		stage = clampi(v, 0, 3)
		_refresh()
@export var planted: bool = true:
	set(v):
		planted = v
		_refresh()
@export var wet: bool = false:
	set(v):
		wet = v
		_refresh()
@export var sparkle_when_ready: bool = true:
	set(v):
		sparkle_when_ready = v
		_refresh()


func _ready() -> void:
	_refresh()


## Bequemer Weg von deinen Beet-Zuständen zur Grafik.
## state: "EMPTY", "GROWING" oder "READY" (oder dein Enum als int 0/1/2).
func set_from_state(state: Variant, progress: float = 0.0) -> void:
	var s := str(state).to_upper()
	if s == "EMPTY" or s == "0":
		planted = false
	elif s == "READY" or s == "2":
		planted = true
		stage = 3
	else:
		planted = true
		stage = clampi(int(progress * 3.0), 0, 2)


func _refresh() -> void:
	if not is_node_ready():
		return
	var plant: Sprite3D = $Plant
	plant.texture = HERB_TEXTURES.get(herb, HERB_TEXTURES["mint"])
	plant.frame = stage
	plant.visible = planted
	$Soil.material_override = SOIL_WET if wet else SOIL_DRY
	var sp: AnimatedSprite3D = $Sparkle
	sp.visible = planted and stage == 3 and sparkle_when_ready
