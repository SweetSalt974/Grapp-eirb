extends State
class_name CharacterHanging

@export var player : CharacterBody2D
@onready var arrow : Node2D = player.get_node("Dash Arrow")
@onready var sprite : Sprite2D = player.get_node("jump")
@onready var animation_player : AnimationPlayer = player.get_node("AnimationPlayer")
@onready var timer : Timer = player.get_node("Timer")

var is_charging : bool = false
var can_dash : bool = false
var has_left : bool = false

func enter() -> void:
	player.rope.clearHighlights()
	player.state_machine.travel("Idle")
	player.global_position = player.rope.global_position 
	player.velocity = Vector2.ZERO
	has_left = false
	can_dash = false
	is_charging = false
	arrow.visible = false

func exit() -> void :
	can_dash = false
	is_charging = false
	arrow.visible = false
	has_left = true
	animation_player.stop()
	animation_player.play("Blinking")
	arrow.self_modulate = Color(Color.WHITE)

func physicsUpdate(_delta : float) -> void:
	var theta_mouse : float = player.get_angle_to(player.get_global_mouse_position())
	arrow.rotation = theta_mouse+PI/4
	if (!is_charging) && (!can_dash): moving()
	if (Input.is_action_just_pressed("climb") && player.rope != null):
		Transitionned.emit(self, "Fall")
	if (Input.is_action_pressed("jump")):
		if !(is_charging) && !(can_dash):
			is_charging = true
			arrow.visible = true
			timer.start()
	if (can_dash):
		if (Input.is_action_just_released("jump")):
			Transitionned.emit(self, "HangingDash")
	if (is_charging):
		if (Input.is_action_just_released("jump")):
			timer.stop()
			is_charging = false
			arrow.visible = false
	if (player.is_on_floor()):
		Transitionned.emit(self , "Idle")
	if (Input.is_action_just_pressed("escape")):
		Transitionned.emit(self, "Paused")

# Code Dash hanging
#				if (can_dash_jump):
#					velocity = Vector2(cos(theta_mouse),sin(theta_mouse))*hanging_dash
#					is_dashing = true
#				else : 
#					velocity = Vector2(cos(theta_mouse),sin(theta_mouse))*150
#					is_dashing = true

func moving():
	var direction : int = floor(Input.get_axis("left", "right"))
	var rope : RigidBody2D = player.rope
	var h_delta : float
	var v_delta : float
	var deg_angle = rad_to_deg(player.rope_angle)
	h_delta = abs(cos(player.rope_angle))
	if (-90 >= deg_angle && deg_angle > -180) : 
		v_delta = sin(player.rope_angle)
	else : 
		v_delta = -sin(player.rope_angle)
	if (rope != null):
		var rope_previous: RigidBody2D
		var rope_next: RigidBody2D
		var is_left := false
		if (rope.is_first): 
			if (rope.musket.ropes[rope.idx-1].position.x < rope.position.x): is_left = true
		else :
			if (rope.musket.ropes[rope.idx+1].position.x > rope.position.x): is_left = true
		player.musket = rope.musket
		if (rope.is_first):
			if (rope.musket.previous_hook is StaticBody2D || rope.musket.previous_hook == null): 
				rope_previous = null
			else :
				var prev_ropes = rope.musket.previous_hook.ropes
				if (prev_ropes[0] is Array): 
					rope_previous = null
				else : rope_previous = prev_ropes[0]
		else : 
			rope_previous = rope.musket.ropes[rope.idx+1]
		if (rope.is_last):
			if (rope.musket.next == null):
				rope_next = null
			else :
				var next_ropes = rope.musket.next.ropes 
				if (next_ropes[0] is Array) :
					rope_next = null
				else : 
					rope_next = next_ropes[rope.musket.next.nb_ropes-1]
		else : 
			rope_next = rope.musket.ropes[rope.idx-1] 
		if (is_left): v_delta *= -1
		if (direction != 0):
			var current_rope : Object = null
			if (direction == 1 ):
				if (is_left):
					current_rope = rope_previous
				else :
					current_rope = rope_next
			elif (direction == -1):
				if (is_left):
					current_rope = rope_next
				else :
					current_rope = rope_previous
			if (current_rope != null):
				var cr_pos : Vector2 = current_rope.position
				#Right
				if (direction == 1):  
					player.position += Vector2(h_delta, -v_delta)
				#Left
				elif (direction == -1):
					player.position += Vector2(-h_delta, v_delta)
				# Snap into position
				if (abs(player.position.x-cr_pos.x) < 10):
					var tween = create_tween()
					tween.tween_property(player,"global_position",current_rope.global_position,0.2)
					player.rope = current_rope
					player.rope_angle = current_rope.getAngle()

func _on_timer_timeout() -> void:
	if (is_charging) && !(has_left):
		animation_player.play("Glowing")
		is_charging = false
		can_dash = true
