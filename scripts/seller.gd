extends Node

@export var sell_area: Sell

func _ready():
	$Timer.timeout.connect(hey_stop_that)

@rpc("any_peer", "call_local", "reliable")
func request_attack(_tool_path: String) -> void:
	$Timer.start()
	$Label3D.visible = true

func interact(_player_id: int):
	sell_area.on_sell_pressed.rpc()

func hey_stop_that():
	$Label3D.visible = false
