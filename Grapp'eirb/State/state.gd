extends Node

class_name State
## Finite State Machine interface. 
##
## A finite state machine is a structure that handles states
## in an optimal and minimal manner. [br]
## It's the best tool to handle a state system for a scene that
## can be comprehensive and maintanable. [br]
## [br]
## This interface declares functions for entering/exiting and 
## the behaviour of the current state

## Signal to transition from a state to another  
signal Transitionned

## Handle code executed when entering current state
func enter() -> void:
	pass

## Handle code executed when exiting current state 
func exit() -> void:
	pass

## Handle code executed in [method Node._process] for current state 
func update(_delta : float) -> void:
	pass

## Handle code executed in [method Node._physics_process] for current state
func physicsUpdate(_delta : float) -> void:
	pass
