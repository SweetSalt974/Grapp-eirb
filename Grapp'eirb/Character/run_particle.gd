extends GPUParticles2D

func fade():
	emitting = false
	var tween = create_tween() 
	tween.tween_property(self, "self_modulate", Color(Color.WHITE, 0.0), 0.5)
	await get_tree().create_timer(0.5).timeout
	queue_free()
