extends Area2D

# Respawn on contact

func _on_body_entered(_body : CharacterBody2D):
	get_parent().get_parent().respawn()
