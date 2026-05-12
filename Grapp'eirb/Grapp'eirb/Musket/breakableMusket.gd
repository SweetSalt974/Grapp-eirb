extends Musket
var still_hanging : bool = false
var is_hanging : bool = true

signal hanging

enum {
	SAFE = 0,
	CRACKED = 1,
	UNSAFE = 2,
	BROKEN = 3
}
func _process(delta: float) -> void:
	super(delta)

func _distributeRope():
	super()
#	for rope in ropes :
#		rope.hanging.connect(playerHanging)

func _on_timer_timeout() -> void:
	pass

#### Some notes for the implementation
# - We need some way to track the player who is putting pressure
# on the ropes. 
# - Deliberate on the way of breaking. Do we break then join 
# the two separate ropes (in case we have this one beetween two)
# OR do we just break everything until the previous_musket of this
# THEN there is also the whole problem if we chain these even though
# it could be fun to force some action and can be a good learning
# experience
# - Other thing, how do we make the ropes free and rebind them ?
# My two cents is simply queue_free() then :
# player.musket_shot = self.previous_musket
# But then the problem is if it is a chained musket there might be a
# lot of implication.
# - Do we implement a state machine ? It might become very Complex
# to handle the different status of break but this might be too much
#### This is not a priority feature but can be fun if I want to 
#### to take this project a bit more seriously
