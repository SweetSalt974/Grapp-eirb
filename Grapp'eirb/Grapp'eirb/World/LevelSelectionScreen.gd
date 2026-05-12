extends Node2D

var state : int = 0

func _ready():
	$LevelHighlight.global_position = Vector2(-8,-31)
	for i in range(0,Global.Collectible.size()):
		if (i < 2):
			var label = get_node("Control/Level"+str(i+1))
			label.text += " : "+str(Global.Collectible[i])+"/2"

func _process(_delta : float) -> void:
	if (Input.is_action_just_pressed("up") && state != 0):
		$LevelHighlight.global_position.y -= 26
		state -= 1
	elif (Input.is_action_just_pressed("down") && state != 1):
		$LevelHighlight.global_position.y += 26
		state += 1
	if (Input.is_action_just_pressed("escape")):
		get_tree().change_scene_to_file("res://selection screen.tscn")
	if (Input.is_action_just_pressed("enter")):
		Global.state = state
		if (state == 0):
			get_tree().change_scene_to_file("res://Grapp'eirb/World/level1.tscn")
		if (state == 1):
			get_tree().change_scene_to_file("res://Grapp'eirb/World/level2.tscn")
#		if (state == 2):
#			get_tree().change_scene_to_file("res://Grapp'eirb/World/level3.tscn")
