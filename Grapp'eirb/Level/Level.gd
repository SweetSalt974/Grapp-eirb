extends Node2D

class_name Level
## Level class
##
## It contains all variable and function to easily
## create a level with screens, respawns and transitions beetween thoses.  

var player : CharacterBody2D
var cam_positions := []
var cam_transitions := [] 
var cam_transitions_path := []
var respawns := []
var follows := []
var can_die : bool 
var idx : int = 0:
	set(new_idx):
		assert(idx>=0, "Level: Set negative idx")
		idx = new_idx
var i : int = 0:
	set(new_i):
		assert(i>=0, "Level: Set negative i")
		i = new_i
var collectible : int = 0:
	set(new_nb):
		assert(new_nb == 1+collectible, "Level: collectible increasing more than 1")
		collectible = new_nb

# Global enum variables
enum {LEFT = Global.LEFT, RIGHT = Global.RIGHT, 
		UP = Global.UP, DOWN = Global.DOWN, 
		UP_C = Global.UP_C
	}

func setLevel(positions: Array, transitions: Array,
				transitions_Path : Array, level_respawns : Array,
				level_follows : Array) -> void:
	self.cam_positions = positions
	self.cam_transitions = transitions
	self.cam_transitions_path = transitions_Path
	self.respawns = level_respawns
	self.follows = level_follows
	self.player = get_node("character")
	self.can_die = false

func addScreen(positions: Array, transitions: Array,
 				transitions_path : Array, level_respawns : Array,
				level_follows : Array) -> void:
	self.cam_positions.append(positions)
	self.cam_transitions.append(transitions)
	self.cam_transitions_path.append(transitions_path)
	self.respawns.append(level_respawns)
	self.follows.append(level_follows)

func reset() -> void:
	get_tree().reload_current_scene()

func getIdx(_idx : int, _i : int) -> void:
	self.idx = _idx
	self.i = _i

func respawn() -> void:
	var cam : Camera2D = get_node("Camera2D")
	var initial_musket : Musket = null
	var current_screen : Node2D = get_node("Screen"+str(idx+1)+str(i))
	player.velocity = Vector2.ZERO
	player.state_machine.travel("death")
	player.get_node("State Machine").current_state.Transitionned.emit(player.get_node("State Machine").current_state, "Paused")
	player.get_node("deathSound").play()
	await get_tree().create_timer(1.2).timeout
	if (current_screen.get_child_count() != 0):
		var children : Array = current_screen.get_children()
		if (children[0] is Musket):
			initial_musket = children[0]
	if (player.musket_shot == null): 
		player.global_position = Vector2(respawns[idx][i][0],respawns[idx][i][1])
		player.get_node("State Machine").current_state.Transitionned.emit(player.get_node("State Machine").current_state, "Idle")
		cam.followAtRespawn()
		return
	if (initial_musket != null):
		player.global_position = Vector2(respawns[idx][i][0],respawns[idx][i][1])
	# We wait that character stop drawing line beetween muskets for angle 
	# too steep so we can clear the lines properly
		await get_tree().create_timer(0.1).timeout
		player.musket_shot.restore()
		player.musket_shot = initial_musket
		initial_musket.player = player
		initial_musket.shoot()
	else :
		player.global_position = Vector2(respawns[idx][i][0],respawns[idx][i][1])
	player.get_node("State Machine").current_state.Transitionned.emit(player.get_node("State Machine").current_state, "Idle")
	cam.followAtRespawn()
