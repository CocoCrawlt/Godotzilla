class_name PlayerSkin
extends Node2D

@export var character_name := ""

@export_group("Character-specific stats")
@export var bar_count := 6
@export var move_state: PlayerCharacter.State
## Character move speed in pixels per frame (in case of 60 fps)
@export var move_speed := 1.0
@export var level_intro_x_start := -35
@export var level_intro_y_offset := 0

@export_group("Character-specific stats/For walking characters")
@export var walk_frame_speed := 9.0
@export var jump_speed := -2 * 60

@export_group("Attacks")
@export var attack_animation_player: AnimationPlayer
@export var attack_hitboxes: Node 
@export var attacks: Array[AttackDescription]

var player: PlayerCharacter
var attack_state_node: Node
var move_state_node: Node

func _ready() -> void:
	if get_parent() is PlayerCharacter:
		player = get_parent()
		attack_state_node = player.state.states_list[PlayerCharacter.State.ATTACK]
		move_state_node = player.state.states_list[move_state]

func walk_process() -> void:
	pass

func common_ground_attacks() -> void:
	if player.inputs_pressed[PlayerCharacter.Inputs.A]:
		player.attack.start_attack("Punch")
	if player.animation_player.current_animation != "Crouch" \
		and player.inputs_pressed[PlayerCharacter.Inputs.B]:
			player.attack.start_attack("Kick")
