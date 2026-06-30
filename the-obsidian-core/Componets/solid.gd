extends Area2D

const SOLID_LAYER := 1

func EnableSolid() -> void:
	set_collision_layer_value(SOLID_LAYER, true)

func DisableSolid() -> void:
	set_collision_layer_value(SOLID_LAYER, false)
