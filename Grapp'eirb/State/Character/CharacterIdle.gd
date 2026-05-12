extends State
class_name CharacterIdle

## State of a [CharacterBody2D] who is on the ground.
##
## Implements the movement on the ground and handle all the sprite work for it.

## Reference for the concerned [CharacterBody2D].
@export var player : CharacterBody2D
@onready var run_effect : PackedScene = preload("res://Grapp'eirb/Character/run_particle.tscn")
@onready var walk : Sprite2D = player.get_node("walk")


var run_instance : GPUParticles2D = null
## Implementation of [CharacterIdle]'s method 
## [method State.physicsUpdate]. [br]
func enter():
	run_instance = null
	var direction = floor(Input.get_axis("left", "right"))
	if (direction != 0):
		run_instance = run_effect.instantiate()
		player.add_child(run_instance)
		run_instance.global_position = player.global_position - Vector2(0,-12)
		run_instance.z_index = -1

func exit():
	if (run_instance != null):
		player.get_parent().add_child(run_instance)
		run_instance.fade()
		run_instance = null

func physicsUpdate(delta : float) -> void:
	var direction = floor(Input.get_axis("left", "right"))
	if direction:
		walk.scale.x = direction
		if (run_instance != null):
			run_instance.process_material.set("gravity", Vector3(45*direction,98,0))
			run_instance.process_material.set("direction", Vector3(-1*direction,0,0))
		if ((abs(player.velocity.x)) < player.max_speed):
			player.velocity.x += direction * player.acc
		else :
			if (direction == 1):
				player.velocity.x = min(player.max_speed, player.velocity.x + player.acc)
			if (direction == -1):
				player.velocity.x = max(-player.max_speed, player.velocity.x - player.acc)
		player.state_machine.travel("walk")
		player.last_direction = direction
	else:
		if abs(player.velocity.x) > 50 :
			if player.velocity.x > 0:
				player.velocity.x -= delta * player.max_speed*5
			if player.velocity.x < 0:
				player.velocity.x += delta * player.max_speed*5
		else:
			player.velocity.x = 0
#				$jump.scale.x = last_direction
		get_parent().get_parent().get_node("idle").scale.x = player.last_direction
		player.state_machine.travel("idle")
	runningParticle()
	if !(player.is_on_floor()):
		Transitionned.emit(self,"Fall")
	if (Input.is_action_just_pressed("jump")):
		Transitionned.emit(self,"Jump")
	if (Input.is_action_just_pressed("climb") && player.rope != null):
		Transitionned.emit(self,"Hanging")
	if (Input.is_action_just_pressed("escape")):
		Transitionned.emit(self, "Paused")

func runningParticle():
	if (run_instance != null):
		if (Input.is_action_pressed("left") && Input.is_action_pressed("right")) :
			player.remove_child(run_instance)
			player.get_parent().add_child(run_instance)
			run_instance.fade()
			run_instance = null
		elif !(Input.is_action_pressed("left")) && !(Input.is_action_pressed("right")):
			player.remove_child(run_instance)
			player.get_parent().add_child(run_instance)
			run_instance.fade()
			run_instance = null 
	else:
		if (Input.is_action_pressed("left") && !Input.is_action_pressed("right")) || (Input.is_action_pressed("right") && !Input.is_action_pressed("left")):
			run_instance = run_effect.instantiate()
			player.add_child(run_instance)
			run_instance.global_position = player.global_position - Vector2(0,-12)
			run_instance.z_index = -1
