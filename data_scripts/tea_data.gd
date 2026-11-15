class_name TeaData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var herb: HerbData
@export var herb_amount: int = 1
## Ziehzeit in Sekunden, beginnt beim Eingießen.
@export var brew_duration: float = 5.0
@export var price: int = 10
## Empfohlene Wassertemperatur in °C. Nur ein Hinweis: Jede Stufe ergibt denselben Tee.
@export var recommended_temperature: int = 90
## Bild der fertigen Tasse, z. B. auf der Ablage.
@export var cup_texture: Texture2D
## Tasse mit Wasser und Sieb, während der Tee zieht.
@export var steeping_cup_texture: Texture2D
