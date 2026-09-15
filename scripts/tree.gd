extends ChoppableTree

@export var value: int

func _ready() -> void:
	chunk_value = value
	set_meta("value", value)
	super._ready()
