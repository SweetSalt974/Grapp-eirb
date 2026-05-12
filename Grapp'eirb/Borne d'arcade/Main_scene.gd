extends Node2D
@onready var start = $Control/VBoxContainer/Start
@onready var quit = $Control/VBoxContainer/Quit

func _ready():
	Global.state = 1
	
func _process(delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://selection screen.tscn")
	


func _on_quit_pressed():
	get_tree().quit()
