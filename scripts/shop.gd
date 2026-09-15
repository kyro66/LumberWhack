extends StaticBody3D

@export var product: ToolData
@export var shop_label: Label3D

func _ready():
	shop_label.text = "$" + str(product.buy_price) + " - " + product.name
	
func interact(_player_id):
	request_purchase.rpc_id(1)
	
@rpc("any_peer", "call_local", "reliable")
func request_purchase() -> void:
	if not multiplayer.is_server(): return
	
	# see who wants to buy it
	var buyer_id := multiplayer.get_remote_sender_id()
	if buyer_id == 0: buyer_id = 1
	
	if product == null: return
	
	if MoneyManager.money < product.buy_price: return
	
	var buyer := get_tree().current_scene.get_node_or_null("Spawners/PlayerSpawner/" + str(buyer_id))
	if buyer == null: return
	
	var buyer_hud := buyer.get_node_or_null("HUD")
	if buyer_hud == null: return
	
	var item_granted: bool = buyer_hud.request_add_item(
		product.resource_path,
		buyer_id
	)
	
	if item_granted: MoneyManager.add_money(-product.buy_price)
	
