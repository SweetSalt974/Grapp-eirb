extends State
class_name CharacterPaused

@export var player : CharacterBody2D
var musket : Node2D
var last_state : State 

func getState(state : State):
	last_state = state

func enter():
	getState(get_parent().current_state)

func physicsUpdate(_delta : float) -> void:
	if (Input.is_action_just_pressed("escape")):
		Transitionned.emit(self, last_state.name.to_lower())

