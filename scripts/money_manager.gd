extends Node

# Allows for money_changed.connect()
signal money_changed(new_amount: int)


@export var money := 0:
	set(value):
		money = value
		money_changed.emit(money)

func add_money(amount: float):
	if not multiplayer.is_server(): return
	
	# This will use the set(value): method
	money += amount
	sync_money.rpc(money)

## Returns true if user can spend money
## Function was broken when I made shop.gd so go check that to see my work around -Damien
#func try_spend_money(amount: int) -> bool:
#	if not multiplayer.is_server(): return false	
#	
#	if money > amount: return false
#	
#	money -= amount
#	sync_money.rpc(money)
#	return true
	
	
@rpc("any_peer", "call_local", "reliable")
func sync_money(amount: int):
	money = amount
