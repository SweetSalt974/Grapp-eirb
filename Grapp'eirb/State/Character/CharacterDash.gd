extends State
class_name CharacterDash

@export var player : CharacterBody2D
@onready var dash_sound : AudioStreamPlayer = player.get_node("dashSound")

var musket : Node2D
var is_falling : bool = false

func enter() -> void:
	is_falling = false
	player.state_machine.travel("jump 2")
	musket = player.musket_shot
	var theta : float = player.get_angle_to(player.get_global_mouse_position())
	player.velocity.x = cos(theta)*400
	if (0 > theta && theta >-3.15):
		var coef = player.get_global_mouse_position().distance_to(player.global_position)
		if (-0.9 > theta && theta > -2.3):
			player.velocity.y = sin(theta)*abs(260 + coef)
		else :
			player.velocity.y = sin(theta)*430
	else :
		player.velocity.y = sin(theta)*530
	await get_tree().create_timer(0.1).timeout
	is_falling = true
	dash_sound.play()

func exit() -> void :
	is_falling = false

func physicsUpdate(delta : float) -> void:
	var direction : int = floor(Input.get_axis("left", "right"))
	if (direction != 0):
		if ((abs(player.velocity.x)) < player.max_speed):
			player.velocity.x += direction * player.acc
		else :
			if (direction == 1):
				player.velocity.x -= player.acc * delta
			if (direction == -1):
				player.velocity.x -= -player.acc * delta
		player.last_direction = direction 
	else :
		var coef : int = abs(player.velocity.x) / player.velocity.x
		if (abs(player.velocity.x) > 25):
			player.velocity.x -= coef * player.max_speed * 3 * delta
		else :
			player.velocity.x = 0
	# Exit condition
	if (player.is_on_floor()):
		Transitionned.emit(self,"Idle")
	if (is_falling):
		Transitionned.emit(self,"Fall")
	if (Input.is_action_just_pressed("climb") && player.rope != null):
		Transitionned.emit(self,"Hanging")
	if (Input.is_action_just_pressed("escape")):
		Transitionned.emit(self, "Paused")
