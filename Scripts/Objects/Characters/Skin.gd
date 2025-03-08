class_name PlayerSkin extends Node2D

@export var character_info: CharacterInfo

@export_group("Gameplay-specific stats")
@export var move_state: PlayerCharacter.State
## Character move speed in pixels per frame (in case of 60 fps)
@export var move_speed := 1.0
@export var level_intro_x_start := -35
@export var level_intro_y_offset := 0

@export_group("Gameplay-specific stats/For walking characters")
@export var walk_frame_speed := 9.0
@export var jump_speed := -2 * 60

@export_group("Gameplay-specific stats/Level Intro", "intro_")
@export var intro_step_sfx_period := 30
@export var intro_step_sfx_start := 15
@export var intro_step_sfx_offset := 10
@export var intro_target_x := 64
		
@export_group("Attacks")
@export var attack_animation_player: AnimationPlayer
@export var attack_function_callback_node: Node
## The Advanced function callbacks will be called on this skin object
@export var attacks: Array[AttackDescription]

@onready var attack_hitboxes: Node2D = $Hitboxes

var player: PlayerCharacter
var attack_state_node: Node
var move_state_node: Node

func _ready() -> void:
	if get_parent() is PlayerCharacter:
		player = get_parent()
		attack_state_node = player.state.states_list[PlayerCharacter.State.ATTACK]
		move_state_node = player.state.states_list[move_state]
	
	attack_hitboxes.hide()
	$Collision.hide()

func walk_process() -> void:
	pass

func common_ground_attacks() -> void:
	if player.inputs_pressed[PlayerCharacter.Inputs.A]:
		player.attack.start_attack("Punch")
	if player.animation_player.current_animation != "Crouch" \
		and player.inputs_pressed[PlayerCharacter.Inputs.B]:
			player.attack.start_attack("Kick")
