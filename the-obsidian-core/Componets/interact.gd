extends RayCast2D

func CheckForInteraction() -> void:
	if is_colliding():
		var obj = get_collider()
		if obj is Interactable:
			obj.TriggerInteraction.emit()
