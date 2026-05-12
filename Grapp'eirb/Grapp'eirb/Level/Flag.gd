extends Area2D

func _on_body_entered(_body : CharacterBody2D):
	if (Global.Collectible[Global.state] < get_parent().collectible):
		Global.Collectible[Global.state] = get_parent().collectible 
	get_tree().change_scene_to_file("res://Grapp'eirb/World/LevelSelectionScreen.tscn")
