extends State

class_name CharacterFalling

@export var player : CharacterBody2D
@onready var sprite : Sprite2D = get_parent().get_parent().get_node("jump")
@onready var scene : Level = get_parent().get_parent().get_parent()
@onready var dust_effect : PackedScene = preload("res://Grapp'eirb/Character/dust_effect.tscn") 

var dust_instance : GPUParticles2D  = null
var can_coyote_jump : bool = false
var last_state : State

func getState(state : State):
	last_state = state

func enter() -> void:
	player.state_machine.travel("jump 2")
	getState(get_parent().current_state)
	if (last_state is CharacterIdle):
		can_coyote_jump = true
		await get_tree().create_timer(0.1).timeout
		can_coyote_jump = false

func exit() -> void :
	dust_instance = null
	can_coyote_jump = false

func physicsUpdate(delta : float) -> void:
	var direction : int = floor(Input.get_axis("left", "right"))
	if (direction != 0):
		if ((abs(player.velocity.x)) < player.max_speed):
			player.velocity.x += direction * player.acc
		else :
			if (direction == 1):
				player.velocity.x = min(player.max_speed, player.velocity.x + player.acc)
			if (direction == -1):
				player.velocity.x = max(-player.max_speed, player.velocity.x - player.acc)
		player.last_direction = direction 
	else :
		var coef : int = abs(player.velocity.x) / player.velocity.x
		if (abs(player.velocity.x) > 50):
			player.velocity.x -= coef * player.max_speed * 6 * delta
		else :
			player.velocity.x = 0
	spriteScale()
	player.velocity.y += player.fall_gravity * delta 
	if (player.is_on_floor()):
		if (direction == 0):
			player.velocity = Vector2.ZERO
		dust_instance = dust_effect.instantiate()
		dust_instance.global_position = Vector2(player.global_position.x,
											player.global_position.y+12)
		scene.add_child(dust_instance)
		Transitionned.emit(self, "Idle")
	if (Input.is_action_just_pressed("climb") && player.rope != null):
		Transitionned.emit(self,"Hanging")
	if (Input.is_action_just_pressed("escape")):
		Transitionned.emit(self, "Paused")
	if (can_coyote_jump):
		if (Input.is_action_just_pressed("jump")):
			Transitionned.emit(self, "Jump")

func spriteScale() -> void:
	if (player.velocity.x == 0) :
		sprite.scale.x = player.last_direction
	if (player.velocity.x > 0) :
		sprite.scale.x = 1
	if (player.velocity.x < 0) :
		sprite.scale.x = -1
