extends CharacterBody2D

@onready var anim_tree := $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]
@onready var finite_state_machine : Node = $"State Machine"

@export var acc : float = 20.0
@export var max_speed := 100.0
@export var jump_height := 30.0
@export var hanging_dash := 500.0
@export var jump_time_to_peak := 0.3
@export var jump_time_to_fall := 0.3
@export_range(1,5) var fast_fall_coef := 2.0
@export_range(0,1) var timer := 0.1

@onready var jump_velocity := (-2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity := (2.0 * jump_height) / (jump_time_to_peak ** 2) 
@onready var fall_gravity := (2.0 * jump_height) / (jump_time_to_fall ** 2)

var last_direction:= 1
var fast_falling := false
var is_paused := false

var theta := 0.0
var last_position := Vector2.ZERO

var musket_shot : Musket = null
var musket : Musket = null
var rope_angle : float = 0.0
var rope : RigidBody2D = null
var i : int = 0

var is_blinking : bool = false

func _ready():
	$idle.visible = 1
	$walk.visible = 0
	$jump.visible = 0
	$death.visible = 0
	$AnimationPlayer.play("Blinking")


# Need to find the logic behind the arrow not dissapearing
func _process(_delta: float) -> void:
	if !(finite_state_machine.current_state is CharacterHanging):
		$"Dash Arrow".visible = false

func _physics_process(_delta : float):
	if (musket_shot != null): drawRope()
	if !(finite_state_machine.current_state is CharacterPaused): move_and_slide()

func drawRope() -> void:
	var line : Line2D = get_node("Line2D")
	var area : Area2D = line.get_node("Area2D")
	var points = PackedVector2Array([to_local(musket_shot.global_position), Vector2(0,0)])
	line.clear_points()
	line.add_point(points[0])
	line.add_point(points[1])
	if (area.get_child_count()!= 0):
		area.get_children()[0].queue_free()
#	var x1 : Vector2 = musket_shot.global_position
#	var x2 : Vector2 = global_position
#	var angle : float = atan2(x1.y-x2.y,x2.x-x1.x)
#	var distance : float = x1.distance_to(x2)
	# Make a breakable rope code here
#	var rect = RectangleShape2D.new()
#	rect.size = Vector2(distance-20,3)
#	var col = CollisionShape2D.new()
#	col.shape = rect
#	col.rotation = -angle
#	col.position += to_local(musket_shot.global_position)/2
#	$Line2D/Area2D.add_child(col)

func storeMuskets(current_hook : Node2D) -> void:
	musket_shot = current_hook

func _on_rope_detector_body_entered(body:RigidBody2D):
	var current_state = get_node("State Machine").current_state
	if !(current_state is CharacterDash) && !(current_state is CharacterHanging):
		if (rope != null && rope != body):
			rope.clearHighlights() 
			body.clearHighlights()
			body.toggleHighlight()
		rope = body

func _on_rope_detector_body_exited(body:RigidBody2D):
	var current_state = get_node("State Machine").current_state
	if !(current_state is CharacterHanging):
		if (rope == body):
			if (rope.highlighted): 
				rope.toggleHighlight()
			rope = null
		else :
			if (body.highlighted): 
				body.toggleHighlight()

func _on_rope_detector_area_entered(area:Area2D):
	if (area.get_parent().get_parent() is Musket):
		var current_state = get_node("State Machine").current_state
		if !(current_state is CharacterHanging):
			area.get_parent().get_parent().drawLine(true)
		else :
			area.get_parent().get_parent().drawLine(false)

func _on_rope_detector_area_exited(area:Area2D):
	var current_state = get_node("State Machine").current_state
	if !(current_state is CharacterHanging) && (area.get_parent().get_parent() is Musket):
		area.get_parent().get_parent().drawLine(false)


