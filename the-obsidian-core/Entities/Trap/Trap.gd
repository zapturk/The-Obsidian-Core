extends Area2D

@onready var sprite = $TrapSprite
var triggered := false

func _ready() -> void:
	# Ensure sprite is hidden at start
	sprite.visible = false
	# Connect the body_entered signal to our handler
	#body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
		
	# Check if the body is the player (assuming player has a name or class check)
	# For now, we show the trap for any body that enters
	triggered = true
	sprite.visible = true
	print("Trap triggered by: ", body.name)
