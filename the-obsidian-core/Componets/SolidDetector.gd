extends RayCast2D
class_name SolidDetector

func is_solid_ahead() -> bool:
	force_raycast_update()
	if is_colliding():
		return true
	return false
