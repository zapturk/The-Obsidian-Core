extends Area2D


func EnableSolid() -> void:
	set_collision_layer_value(1, true)
	
	
func DisableSolid() -> void:
	set_collision_layer_value(1, false)
