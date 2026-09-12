extends Node

@export var area: Area3D
@export var value_display: Label3D

var sell_queue: Array[Node3D]
var sell_queue_value: float

var sell_debounce: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server(): return
	
	# Initialize the sell queue to empty
	sell_queue = []
	sell_queue_value = 0.0
	
	# Create signal so that whenever an item enters the Area3D it is added to the sell queue
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exit)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	# Initialize the debounce for selling
	sell_debounce = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not multiplayer.is_server(): return
	pass


func _on_body_entered(node: Node3D):
	if not multiplayer.is_server(): return
	
	# Check if the item has value metadata
	if not node.has_meta('value'): return
	
	# ensure the item is not already in the queue
	if node in sell_queue: return
	
	# Add the node3d to the sell queue
	sell_queue.append(node)
	
	# add the value to the sell queue value total
	sell_queue_value += node.get_meta('value')
	
	print("entered")
	update_money_display.rpc(sell_queue_value)
	
func _on_body_exit(node: Node3D):
	
	if not multiplayer.is_server(): return
	
	if not node.has_meta('value'): return
	
	if not node in sell_queue: return
	
	sell_queue.remove_at(sell_queue.find(node))
	sell_queue_value -= node.get_meta("value")
	
	print("left")
	update_money_display.rpc(sell_queue_value)
	
@rpc("any_peer", "call_local", "reliable")
func on_sell_pressed():
	if not multiplayer.is_server(): return
	if sell_debounce: return
	
	sell_debounce = true
	
	
	
	# Loop through all the items in sell queue
	for valuable: Node3D in sell_queue:
		
		if is_instance_valid(valuable):
		# Delete the instantiatated item
			valuable.queue_free()
	
	sell_queue.clear()
	sell_queue_value = 0
	update_money_display.rpc(sell_queue_value)
	
	sell_debounce = true


@rpc("authority", "call_local", "reliable")
func update_money_display(new: float):
	sell_queue_value = new
	value_display.text = 'Value: %.2f' % [sell_queue_value] 
	
func _on_peer_connected(id: int):
	
	update_money_display.rpc_id(id, sell_queue_value)
	
	
