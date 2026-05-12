extends Node2D
@onready var boulder_preload = preload("res://Grapp'eirb/Level/boulder.tscn")
var boulder

func _ready():
	boulder = boulder_preload.instantiate()
	get_parent().add_child(boulder)
	boulder.init_pos = get_parent().get_node("character").global_position
	print(boulder.init_pos)
	boulder.global_position = get_parent().get_node("character").global_position 
	boulder.global_position.y -= 300
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print(boulder.position)
	pass
