extends Level

# Called when the node enters the scene tree for the first time.
func _ready():
		# setLevel(Positions, Transitions, TransitionsPaths, Respawns, follow_width)
	setLevel([[[750,0]]], [], [], [[[-23,-26]]], [[1800]])
	get_node("Screen10/hangingMusket2").fakeShoot()
func _process(delta):
	if (Input.is_action_just_pressed("Retour")):
		get_tree().change_scene_to_file("res://Grapp'eirb/World/LevelSelectionScreen.tscn")
	if (Input.is_action_just_pressed("enter")):
		reset()
	if (Input.is_action_just_pressed("respawn") && player.is_on_floor()):
		respawn()
