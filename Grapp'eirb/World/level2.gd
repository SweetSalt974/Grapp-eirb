extends Level

@onready var settings := $"Camera2D/settings"
@onready var camera := $"Camera2D"

func _ready():
	#Positions, Transitions, TransitionsPath, Respawns, pos_following
	#screen 10
	setLevel([[[-90,-15]]], [], [], [[[-382,-56]]], [[715]])
	#screen 20, 21
	addScreen([
	[613,-68], [-90,-288]],
	[[317,-23],[220,-121]],
	[RIGHT,UP],
	[[443,-20], [224,-230]],
	[0, 715])
	#screen 30
	addScreen(
	[[792,-347]],
	[[779,-187]],
	[UP_C],
	[[786,-16]],
	[0])
	#screen 40
	addScreen(
	[[846,-514]],
	[[794, -442]],
	[UP_C],
	[[833,-465]],
	[0])
	#Prepare hanging ropes
	var musket : Musket = get_node("Screen20").get_node("Musket with hooks3")
	var musket1 : Musket = get_node("Screen30").get_node("Musket with hooks2")
	var musket2 : Musket = get_node("Screen30").get_node("Musket with hooks3")
	musket.fakeShoot()
	musket1.fakeShoot()
	musket2.fakeShoot()
	settings.visible = 0

func _process(delta):
	if (Input.is_action_just_pressed("Retour")):
		get_tree().change_scene_to_file("res://Grapp'eirb/World/LevelSelectionScreen.tscn")
	if (Input.is_action_just_pressed("enter")):
		reset()
	if (Input.is_action_just_pressed("respawn") && player.is_on_floor()):
		respawn()
#	if (Input.is_action_just_pressed("escape") && settings.visible):
#		camera.global_position = Vector2(CamPositions[idx][i][0],CamPositions[idx][i][1])
#	if (settings.visible):
#		camera.global_position = Vector2(-300,180)
