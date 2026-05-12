extends Node2D
@onready var init_pos = global_position 

func _process(delta):
	position.y += 150*delta
	if (global_position.y > init_pos.y+800):
		self.queue_free()
