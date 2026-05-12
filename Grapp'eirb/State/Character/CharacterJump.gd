extends State
class_name CharacterJump

@export var player : CharacterBody2D
@onready var sprite : Sprite2D = get_parent().get_parent().get_node("jump")
@onready var jump_sound : AudioStreamPlayer = player.get_node("jumpSound")

func enter() -> void:
	player.velocity.y = player.jump_velocity 
	player.state_machine.travel("jump")
	jump_sound.play()

## Implementation of [CharacterJump]'s method 
## [method State.physicsUpdate]. [br]
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
	_spriteScale()
	if (player.velocity.y > 0.0):
		player.velocity.y += player.jump_gravity * delta
	elif (player.velocity.y < 0.0):
		Transitionned.emit(self,"Fall")
	if (player.is_on_floor()):
		Transitionned.emit(self, "Idle")
	if (Input.is_action_just_pressed("climb") && player.rope != null):
		Transitionned.emit(self, "Hanging")
	if (Input.is_action_just_pressed("escape")):
		Transitionned.emit(self, "Paused")

func _spriteScale() -> void:
	if (player.velocity.x == 0) :
		sprite.scale.x = player.last_direction
	if (player.velocity.x > 0) :
		sprite.scale.x = 1
	if (player.velocity.x < 0) :
		sprite.scale.x = -1
