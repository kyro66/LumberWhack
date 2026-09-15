extends VehicleBody3D

@export var MAX_STEER: float = 0.9
@export var ENGINE_POWER: int = 1000

func _physics_process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis('move_right', 'move_left') * MAX_STEER, delta * 10)
	engine_force = Input.get_axis("move_down", 'move_up') * ENGINE_POWER
