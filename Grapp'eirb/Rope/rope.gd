extends RigidBody2D
class_name Rope

var has_changed := false
var highlighted := false
var idx : int = -1 : 
	set(new_idx):
		assert(new_idx>=0,"Objet Rope: Set negative idx")
		idx = new_idx
var is_last := false
var is_first := false
var musket : Node2D = null
var is_connected_rope = false

func setRopes(_idx : int, _musket : Node2D) -> void:
	self.idx = _idx
	self.musket = _musket

func clearHighlights() -> void:
	for i in range(0,musket.nb_ropes):
		if (musket.ropes[i].highlighted): musket.ropes[i].toggleHighlight()

func toggleHighlight() -> void:
	if ($Normal.visible == true): 
		$Normal.visible = false
		$Highlight.visible = true
		highlighted = true
	else :
		$Normal.visible = true
		$Highlight.visible = false
		highlighted = false

func getAngle() -> float:
	var angle: float
	var pos1 : Vector2
	var pos2 : Vector2
	if (is_last && musket.next != null):
		pos1 = global_position
		if (musket.next.ropes[0] is Array) :
			return 0
		else : 
			pos2 = musket.next.ropes[musket.next.nb_ropes-1].global_position
		angle = atan2(abs(pos1.x-pos2.x),
					 abs(pos1.y - pos2.y))
	else :
		pos1 = musket.ropes[idx-1].global_position
		pos2 = global_position 
		angle = atan2(abs(pos1.x-pos2.x),
					 abs(pos1.y - pos2.y))
		# Adjust angle if is above-below and if left-right 
	if (pos1.y > pos2.y): 
		angle = -angle + PI/2
	else :
		angle -= PI/2
	return angle

func connectHanging():
	musket.hanging.connect()
	is_connected_rope = true
