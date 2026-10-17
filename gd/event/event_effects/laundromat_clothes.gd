@tool
class_name LaundromatClothes
extends EventEffect

func apply(_player: PlayerState, event: Event) -> void:
	var roll: int = randi_range(1, 5)
	
	match roll:
		1, 2:
			event.set_value(&"result", "TID_LAUNDROMAT_CLOTHES_SAFE")
		3:
			if !event.get_value(&"saved_panties_removed", true):
				event.set_value(&"saved_panties_removed", true)
				event.set_value(&"result", "TID_LAUNDROMAT_PANTIES_STOLEN")
			else:
				event.set_value(&"result", "TID_LAUNDROMAT_CLOTHES_SAFE")
		4:
			if event.get_value(&"saved_clothes_state", PlayerState.ClothesState.REMOVED) != PlayerState.ClothesState.REMOVED:
				event.set_value(&"saved_clothes_state", PlayerState.ClothesState.REMOVED)
				event.set_value(&"result", "TID_LAUNDROMAT_CLOTHES_STOLEN")
			else:
				event.set_value(&"result", "TID_LAUNDROMAT_CLOTHES_SAFE")
		5:
			event.set_value(&"saved_clothes_state", PlayerState.ClothesState.REMOVED)
			event.set_value(&"saved_panties_removed", true)
			event.set_value(&"result", "TID_LAUNDROMAT_ALL_CLOTHES_STOLEN")
