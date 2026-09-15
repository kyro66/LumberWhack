class_name ToolData
extends Resource

enum ToolType {AXE, KNIFE, SAW}

@export var name: String
@export var icon: Texture2D
@export var scene: PackedScene
@export var type: ToolType
@export var power: int
@export var value: int
@export var buy_price: int
@export var cooldown: int = 1

func _ready() -> void:
	set_meta("value", value)
