class_name DecorationData
extends Resource
## Eine kaufbare Dekoration aus dem Einrichtungskatalog (Spec 9).
## Wo sie in der Welt steht, legt ihr DecorationSpot fest.

@export var id: String = ""
@export var display_name: String = ""
@export var price: int = 10
## Vorschaubild im Katalog.
@export var icon: Texture2D
