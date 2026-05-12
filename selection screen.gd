extends Node2D
@onready var animation = $AnimationPlayer
@onready var title_cards = $"scrolling title cards"
var state = 1
var new_position : int = 0
var is_transitionning := false
# Called when the node enters the scene tree for the first time.
func _ready():
	title_cards.position.x = -256 - 512*state
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
##### ADD TWEENING WHERE THERE IS "PASS" 
#		if (Input.is_action_just_pressed("left")):
#			animation.play("turn_left")
#			if (title_cards.position.x != -128):
#				pass
#				state-=1
#		if (Input.is_action_just_pressed("right")):
#			animation.play("turn_right")
#			if (title_cards.position.x != -128-256*6):
#				pass
#				state+=1
		if (is_transitionning):
			$Label.visible = false
			if ($Camera2D.zoom.x < 7): 
				$Camera2D.zoom += delta*Vector2(1,1)*6
				$Camera2D.position.y -= 92*delta
			else :
				if (state == 1):
					get_tree().change_scene_to_file("res://Grapp'eirb/World/LevelSelectionScreen.tscn")
		if (Input.is_action_just_pressed("enter") && !is_transitionning):
#			if (state == 0):
#				get_tree().change_scene_to_file("res://Gravit'eirb/main.tscn")
			if (state == 1):
				is_transitionning = true
#				get_tree().change_scene_to_file("res://Grapp'eirb/World/level1.tscn")
#			if (state == 2):
#				get_tree().change_scene_to_file("res://SuperMarioBug'eirb/Scenes/overworld.tscn")
