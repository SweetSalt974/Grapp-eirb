extends Node2D

class_name Musket

@export var used : bool = false
@onready var animate : AnimationPlayer = $"musket/AnimationPlayer"
@onready var outline : Sprite2D = $"musket/outline"
@onready var rope_preload : PackedScene = preload("res://Grapp'eirb/Rope/rope.tscn")
@onready var node : Node2D = get_parent().get_parent()
@export var previous_hook : Node2D = null
@onready var line2d : Line2D = $Line2D 

var player : CharacterBody2D = null 
var next : Node2D = null
var ropes : Array = []
var joints : Array[PinJoint2D] = []
var mouse_in : bool = false
var distance : float
var angle : float 
var nb_ropes : int:
	set(new_nb):
		assert(new_nb>=0, "Musket: Try to set negative nb_ropes")
		nb_ropes = new_nb 
var was_added : bool = false

func _ready() -> void:
	animate.play("spinning")
	outline.modulate.a = 0.3

func _process(_delta : float) -> void:
	if (!used):
		if (mouse_in && player != null):
			if (Input.is_action_just_pressed("shoot")):
#				# Toggle dash 
				player.storeMuskets(self)
				var state_machine = node.get_node("character").get_node("State Machine")
				state_machine.on_child_transition(
					state_machine.current_state, "Dash")
				shoot()

func shoot() -> void:
	# Create and store ropes
	player.storeMuskets(self)
	var current_hook : Node2D = self
	# create ropes for all hook
#	for hook in player.muskets:
	while(current_hook != null && current_hook is Musket):
		if !(current_hook.used):
			current_hook.used = true
			current_hook.outline.visible = 0
			current_hook._setAngleDistance()
			current_hook._createRope()
			if (current_hook.previous_hook is Musket && current_hook.previous_hook != null):
				current_hook.previous_hook.next = current_hook
			current_hook = current_hook.previous_hook
		else : break

func fakeShoot() -> void:
	var current_hook : Node2D = self
	# create ropes for all hook
#	for hook in player.muskets:
	while(current_hook != null && !(current_hook is StaticBody2D)):
		if !(current_hook.used):
			current_hook.used = true
			current_hook.outline.visible = 0
			current_hook._setAngleDistance()
			current_hook._createRope()
			if !(current_hook.previous_hook is StaticBody2D) && (current_hook.previous_hook != null):
				current_hook.previous_hook.next = current_hook
			current_hook = current_hook.previous_hook
		else : break

func _setFree() -> void:
	self.was_added = false
	self.used = false
	self.outline.visible = 1
	self.next = null
	line2d.clear_points()
	for child in $Line2D/Area2D.get_children():
		child.queue_free()
	for rope in ropes :
		if !(rope is Array):
			rope.queue_free()
	ropes = []
	for joint in joints :
		joint.queue_free()
	joints = []

func restore() -> void:
	var current_hook = self
	while(current_hook != null && !(current_hook is StaticBody2D)):
		current_hook._setFree()
		current_hook = current_hook.previous_hook

func _createRope() -> void:
	var step_vector = Vector2(cos(angle)*16,-sin(angle)*16)
	if(abs(rad_to_deg(angle)) < 45 || abs(rad_to_deg(angle)) > 135):
		var current_position : Vector2 = global_position
		nb_ropes = floor(distance/16)+1
		for i in nb_ropes:
			# rope n°i
			var rope : Object = rope_preload.instantiate()
			rope.z_index = 0
			if (abs(rad_to_deg(angle)) < 45):
				rope.global_position = current_position-Vector2(7.5,0)
			else : 
				rope.global_position = current_position
			rope.rotation = -angle
			node.add_child(rope)
			# joints n°i 
			var joint := PinJoint2D.new()
			joint.softness = 0.01
			joint.global_position = current_position
			joint.node_a = rope.get_path()
			if (i == 0): 
				joint.node_b = get_node("hook").get_path()
			else : joint.node_b = ropes[i-1].get_path()
			node.add_child(joint)
			#Add in musket arrays
			ropes.append(rope)
			joints.append(joint)
			# Last joint
			if (i == nb_ropes-1): 
				var last_joint := PinJoint2D.new()
				last_joint.softness = 0.01
				last_joint.global_position = previous_hook.global_position
				if (abs(rad_to_deg(angle)) < 45):
					last_joint.node_b = ropes[i].get_path()
					if (previous_hook is StaticBody2D): last_joint.node_a = previous_hook.get_path()
					elif (previous_hook is Musket): last_joint.node_a = previous_hook.get_node("hook").get_path()
				else : 
					last_joint.node_a = ropes[i].get_path()
					if (previous_hook is StaticBody2D): last_joint.node_b = previous_hook.get_path()
					elif (previous_hook is Musket): last_joint.node_b = previous_hook.get_node("hook").get_path()
				node.add_child(last_joint)
				joints.append(last_joint)
			# next rope and joint position
			current_position -= step_vector 
		_distributeRope()
	else :
		drawLine(false)

func drawLine(is_selected : bool) -> void:
	var line = $Line2D
	var step_vector := Vector2(cos(angle)*16,-sin(angle)*16)
	var phook_pos := to_local(previous_hook.global_position)+1.6*step_vector
	line.clear_points()
	line.add_point(Vector2(0,0))
	line.add_point(phook_pos)
	var rect := RectangleShape2D.new()
	rect.size = Vector2(distance-18,3)
	var col := CollisionShape2D.new()
	col.shape = rect
	col.rotation = -angle
	col.position += phook_pos/2
	$Line2D/Area2D.add_child(col)
	if (!was_added):
		self.ropes.append([to_global(phook_pos),to_global(Vector2(0,0))])
		was_added = true
	if (is_selected): line.default_color.a = 0.2
	else : line.default_color.a = 1.0

func _distributeRope() -> void:
	for idx in range(0,nb_ropes):
		ropes[idx].setRopes(idx, self)
		if (idx == 0): 
			ropes[idx].is_last = true
		elif (idx == nb_ropes-1): ropes[idx].is_first = true

func _setAngleDistance() -> void:
	angle = _getAngle()
	distance = _getDistance()

func _getDistance() -> float:
	var x1 : Vector2 = previous_hook.global_position
	var x2 : Vector2 = global_position
	return x2.distance_to(x1)

func _getAngle() -> float:
	var x1 : Vector2 = previous_hook.global_position
	var x2 : Vector2 = global_position
	return atan2(x1.y-x2.y,x2.x-x1.x)

func _on_visibility_body_entered(body:CharacterBody2D) -> void:
	player = body
	outline.modulate.a = 1

func _on_visibility_body_exited(_body:CharacterBody2D) -> void:
	player = null
	outline.modulate.a = 0.3

func _on_detection_mouse_entered() -> void:
	mouse_in = true

func _on_detection_mouse_exited() -> void:
	mouse_in = false

