extends Level

@onready var settings := $"Camera2D/settings"
@onready var camera := $"Camera2D"
@onready var tutoMusket : Musket = get_node("Screen30/Musket with hooks4") 
@onready var resetMusket : Musket = get_node("Screen10/Musket with hooks3")
@onready var playerStateMachine : Node = get_node("character").get_node("State Machine")

var tutoStatus : int = 0
var tuto2Status : int = 0
var tuto2Shot := false


func _ready():
	# setLevel(Positions, Transitions, TransitionsPaths, Respawns, follow_width)
	#screen 10
	setLevel([[[-300,182]]], [], [], [[[-563,312]]], [[0]])
	#screen 20
	addScreen([[60,-128]], [[-192,24]], [UP_C], [[-112,14]], [0])
	#screen 30
	addScreen([[165,-362]], [[165,-209]], [UP], [[204,-281]], [0])
	#screen 40,41,42
	addScreen([[-265,-427],[551,-468],[130,-681]]
			,[[2,-431], [289,-426],[170,-502]]
			,[LEFT,RIGHT,UP] 
			,[[-75,-421],[477,-420],[202,-532]]
			,[0,0,0])
func _process(_delta : float) -> void:
	if (Input.is_action_just_pressed("Retour")):
		get_tree().change_scene_to_file("res://Grapp'eirb/World/LevelSelectionScreen.tscn")
	if (Input.is_action_just_pressed("enter")):
		reset()
	if (Input.is_action_just_pressed("respawn") && player.is_on_floor()):
		respawn()
#	if (Input.is_action_just_pressed("escape") && settings.visible):
#		camera.global_position = Vector2(cam_positions[idx][i][0],cam_positions[idx][i][1])
#	if (settings.visible):
#		camera.global_position = Vector2(-300,180)
	# Tutoriel bit 
	if (tutoStatus != 4):
		if (tutoStatus == 0 && player.musket_shot == tutoMusket):
			var tween = create_tween()
			tween.tween_property($Tuto/Control/Hanging,"self_modulate",Color(Color.WHITE,1),0.5)
			tutoStatus = 1
		elif (tutoStatus == 1):
			if (playerStateMachine.current_state is CharacterHanging && idx == 2 && i == 0):
				var tween = create_tween()
				tween.tween_property($Tuto/Control/Hanging,"self_modulate",Color(Color.WHITE,0),0.5)
				tutoStatus = 2
		elif (tutoStatus == 2 && $Tuto/Control/Hanging.self_modulate.a == 0):
			$Tuto/Control.position.x -= 100
			$Tuto/Control/Hanging.text = "Maintenir sur corde: ESPACE -> Dash ++"
			var tween = create_tween()
			tween.tween_property($Tuto/Control/Hanging,"self_modulate",Color(Color.WHITE,1),1)
			tutoStatus = 3
		elif (tutoStatus == 3):
			if (playerStateMachine.current_state is CharacterHanging && Input.is_action_just_pressed("jump")&& idx == 2 && i == 0):
				var tween = create_tween()
				tween.tween_property($Tuto/Control/Hanging,"self_modulate",Color(Color.WHITE,0),0.5)
				tutoStatus = 4
	if (tuto2Status == 0):
		if (idx == 0):
			if !(tuto2Shot) && (player.musket_shot == resetMusket):
				tuto2Shot = true
			if (tuto2Shot && player.global_position.y > 311):
				var resetTween2 = create_tween()
				resetTween2.tween_property($Tuto/Reset2, "self_modulate", Color(Color.WHITE, 1), 0.5)
				tuto2Status = 1
		if (idx == 1 && i == 0):
			var resetTween = create_tween()
			resetTween.tween_property($Tuto/Reset, "self_modulate", Color(Color.WHITE, 1), 0.5)
			tuto2Status = 2
	elif (tuto2Status == 1):
		if (idx == 0):
			if (Input.is_action_just_pressed("respawn") && player.is_on_floor()):
				var tween = create_tween()
				tween.tween_property($Tuto/Reset2, "self_modulate", Color(Color.WHITE, 0), 0.5)
				tuto2Status = 3
	elif (tuto2Status == 2):
		if (idx == 1 && i == 0):
			if (Input.is_action_just_pressed("respawn") && player.is_on_floor()):
				var tween = create_tween()
				tween.tween_property($Tuto/Reset, "self_modulate", Color(Color.WHITE, 0), 0.5)
				tuto2Status = 3

func _on_dash_body_entered(_body: CharacterBody2D) -> void:
	var tween = create_tween()
	tween.tween_property($Tuto/Dash,"self_modulate",Color(Color.WHITE,1),0.5)


func _on_dash_body_exited(_body: CharacterBody2D) -> void:
	var tween = create_tween()
	tween.tween_property($Tuto/Dash,"self_modulate",Color(Color.WHITE,0),0.5)
