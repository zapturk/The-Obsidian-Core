extends RayCast2D

func SetTargetPosition(target_pos: Vector2) -> void:
	target_position = target_pos
	force_raycast_update()

func CheckForInteraction() -> void:
	if is_colliding():
		var obj = get_collider()
		if obj is Interactable:
			obj.TriggerInteraction.emit()
