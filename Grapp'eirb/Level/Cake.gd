extends Area2D
@onready var level : Level = get_parent().get_parent()
var is_eaten : = false


func _on_body_entered(_body:CharacterBody2D):
	if !(is_eaten):
		$Sprite2D.visible = false
		level.collectible += 1
		is_eaten = true
		$particleCake/GPUParticles2D.set_emitting(true)
		await get_tree().create_timer(0.8).timeout
		$particleCake/GPUParticles2D.set_emitting(false)
