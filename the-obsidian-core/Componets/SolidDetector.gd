extends RayCast2D
class_name SolidDetector

func SetTargetPosition(target_pos: Vector2) -> void:
	target_position = target_pos
	force_raycast_update()

func IsSolidAhead() -> bool:
	if is_colliding():
		return true
	return false
