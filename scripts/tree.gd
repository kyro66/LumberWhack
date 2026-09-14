extends ChoppableTree

@export var value: int

func _ready() -> void:
	set_meta("value", value)
