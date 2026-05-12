extends Camera2D

@onready var level : Level = get_parent()
var player : CharacterBody2D
var cam_positions : Array = []
var cam_transitions : Array = []
var cam_transitions_path : Array = []
var pos_follows : Array = []
var idx : int = 0
var nb_transitions : int = 0
var toggle_next : bool = false
var toggle_prev : bool = false
var done : bool = false
var last_direction : Array[int] = []
var directions_idx : int = -1
var last_sub_index : Array[int] = []
var last_i_idx : int = -1
var i : int = 0
var is_paused : bool = false

var current_limits : Array[Vector2] = [Vector2.ZERO,Vector2.ZERO]
var follow_tween : Tween 
const SMOOTHING_FACTOR : int = 30 
const SNAPPING_FACTOR : int = 150

@onready var player_state_machine : Node = get_parent().get_node("character").get_node("State Machine")

func _physics_process(delta: float) -> void:
	if !(is_paused):
		var follow_width : int = pos_follows[idx][i]
		if (follow_width != 0): follow(delta,follow_width)

func _process(_delta: float) -> void:
	var will_transitione := false
	if (idx < nb_transitions):
		for i in range(0,cam_transitions_path[idx].size()):
			match cam_transitions_path[idx][i]:
				Global.LEFT:
					if (cam_transitions[idx][i][0] > player.global_position.x):
						will_transitione = true
				Global.RIGHT:
					if (cam_transitions[idx][i][0] < player.global_position.x):
						will_transitione = true
				Global.UP:
					if (cam_transitions[idx][i][1] > player.global_position.y):
						will_transitione = true
				Global.UP_C:
					if (cam_transitions[idx][i][1] > player.global_position.y) && (abs(cam_transitions[idx][i][0]-player.global_position.x) < 120):
						will_transitione = true
				Global.DOWN:
					if (cam_transitions[idx][i][1] < player.global_position.y):
						will_transitione = true
			if (will_transitione):
				last_direction.append(cam_transitions_path[idx][i])
				directions_idx +=1
				last_sub_index.append(self.i)
				last_i_idx += 1
				self.i = i
				idx += 1
#				if (follow_tween[idx,i])
				smoothCamTransition()
				get_parent().getIdx(idx, i)
				break
	will_transitione = false
	if (idx > 0):
		for i in range(0,cam_transitions_path[idx-1].size()):
			match cam_transitions_path[idx-1][i]:
				Global.LEFT:
					if (cam_transitions[idx-1][i][0] < player.global_position.x):
						if (last_direction[directions_idx] == cam_transitions_path[idx-1][i]):
							will_transitione = true
				Global.RIGHT:
					if (cam_transitions[idx-1][i][0] > player.global_position.x):
						if (last_direction[directions_idx] == cam_transitions_path[idx-1][i]):
							will_transitione = true
				Global.UP:
					if (cam_transitions[idx-1][i][1] < player.global_position.y):
						if (last_direction[directions_idx] == cam_transitions_path[idx-1][i]):
							will_transitione = true
				Global.UP_C:
					if (cam_transitions[idx-1][i][1] < player.global_position.y) && (abs(cam_transitions[idx-1][i][0]-player.global_position.x) < 120):
						if (last_direction[directions_idx] == cam_transitions_path[idx-1][i]):
							will_transitione = true
				Global.DOWN:
					if (cam_transitions[idx-1][i][1] > player.global_position.y):
						if (last_direction[directions_idx] == cam_transitions_path[idx-1][i]):
							will_transitione = true
			if (will_transitione):
				var prev_i : int
				if (last_sub_index.size() > 0):
					prev_i = last_sub_index[last_i_idx-1]
				else :
					prev_i = 0 
				last_direction.remove_at(directions_idx)
				directions_idx -= 1
				last_sub_index.remove_at(last_i_idx)
				last_i_idx -= 1
				idx -= 1
				self.i = prev_i 
				smoothCamTransition()
				get_parent().getIdx(self.idx, self.i)
				break
	if (Input.is_action_just_pressed("escape")):
		pauseCam()

func pauseCam():
	var follow_width = pos_follows[idx][i]
	if ($settings.visible == false):
		zoom = Vector2(1.5,1.5)
		global_position = Vector2(-300,180)
		$settings.visible = true
		is_paused = true
		for tween in get_tree().get_processed_tweens():
			tween.stop()
	elif ($settings.visible == true):
		zoom = Vector2(3,3)
		if (follow_width != 0):
			global_position = Vector2(player.global_position.x,
									cam_positions[idx][self.i][1])
		else :
			global_position = Vector2(cam_positions[idx][self.i][0],
									cam_positions[idx][self.i][1])
		$settings.visible = false
		is_paused = false
		for tween in get_tree().get_processed_tweens():
			tween.play()

## Scripts for following cam
func follow(delta : float, width : int) -> void:
	var direction : int = floor(Input.get_axis("left","right"))
	if (direction != 0):
#		follow_tween.pause()
		if (direction == 1):
			if (player.global_position.x < current_limits[1].x-160):
				if (global_position.x < player.global_position.x-SMOOTHING_FACTOR):
					global_position.x = player.global_position.x-SMOOTHING_FACTOR
		elif (direction == -1):
			if (player.global_position.x > current_limits[0].x+160):
				if (global_position.x > player.global_position.x+SMOOTHING_FACTOR):
					global_position.x = player.global_position.x+SMOOTHING_FACTOR
	else :
		var coef = global_position.x - player.global_position.x
		if (coef >= 0): coef = 1
		else : coef = -1
		var cond_player_at_left : bool = (coef == 1 && player.global_position.x > current_limits[0].x+160)
		var cond_player_at_right : bool = (coef == -1 && player.global_position.x < current_limits[1].x-160)
		if (cond_player_at_left || cond_player_at_right) :
			if abs(global_position.x-player.global_position.x)>2:
				global_position.x -= SNAPPING_FACTOR*coef*delta

func smoothCamTransition() -> void:
	var follow_width : int = pos_follows[idx][i]
	var new_cam_pos : Vector2 = Vector2(cam_positions[idx][i][0],cam_positions[idx][i][1])
	if (follow_width != 0):
		var tween := create_tween()
		var new_global_position : Vector2 
		if (player.global_position.x > new_cam_pos.x-(follow_width/2)+160) && (player.global_position.x < new_cam_pos.x+(follow_width/2)-160):
			new_global_position = Vector2(player.global_position.x,new_cam_pos.y)
		else :
			if (new_cam_pos.x-player.global_position.x>0):
				new_global_position = Vector2(new_cam_pos.x-(follow_width/2)+160,
											new_cam_pos.y)
			else :
				new_global_position = Vector2(new_cam_pos.x+(follow_width/2)-160,
											new_cam_pos.y)
		tween.tween_property(self,"global_position",
								new_global_position,
								0.7)
	else :
		var tween = create_tween() 
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(self,"global_position",
							Vector2(cam_positions[self.idx][self.i][0],
									cam_positions[self.idx][self.i][1]),
							0.7
							) 

func setCams() -> void:
	cam_positions = level.cam_positions
	cam_transitions = level.cam_transitions
	cam_transitions_path = level.cam_transitions_path
	pos_follows = level.follows
	player = level.get_node("character")
	var half_follow_width = pos_follows[0][0]/2
	current_limits[0] = Vector2(cam_positions[0][0][0]-half_follow_width,cam_positions[0][0][1])
	current_limits[1] = Vector2(cam_positions[0][0][0]+half_follow_width,cam_positions[0][0][1])
	if (pos_follows[0][0] != 0):
		if (player.global_position.x > current_limits[0].x):
			global_position = Vector2(player.global_position.x,current_limits[0].y)
		else:
			global_position = current_limits[0]
	else :
		global_position = Vector2(cam_positions[0][0][0],cam_positions[0][0][1])
	assert(cam_positions.size() == cam_transitions.size()+1,"Error Camera2D : Too many positions or transitions in Level")
	nb_transitions = cam_transitions.size()

func followAtRespawn() -> void:
	var follow_width : int = pos_follows[idx][i]
#	zoom = Vector2(1.5,1.5)
#	global_position = Vector2(-300,180)
#	$respawn.visible = true
#	await get_tree().create_timer(0.3).timeout
#	global_position = Vector2(cam_positions[idx][i][0],
#							cam_positions[idx][i][1])
#	zoom = Vector2(3,3)
#	print(zoom)
#	$respawn.visible = false
#	player_state_machine.current_state.Transitionned.emit(player_state_machine.current_state, "Fall")
	if (follow_width != 0):
		global_position.x = player.global_position.x
		global_position.y = cam_positions[idx][i][1]
	else :
		global_position = Vector2(cam_positions[idx][i][0],
								cam_positions[idx][i][1])

# Change with generic signal
# signal SetCams simply

func _on_level_1_ready():
	setCams()

func _on_level_2_ready():
	setCams()

func _on_level_3_ready():
	setCams()
