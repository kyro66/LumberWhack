class_name ToolData
extends Resource

enum ToolType {AXE, KNIFE, SAW}

@export var name: String
@export var icon: Texture2D
@export var scene: PackedScene
@export var type: ToolType
@export var power: int
