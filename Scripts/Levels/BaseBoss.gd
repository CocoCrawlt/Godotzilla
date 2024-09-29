extends Level

## The amount of XP the player gets when the boss is defeated
@export var xp_amount := 100
## The amount of score the player gets when the boss is defeated
@export var score_amount := 110000

@onready var boss: PlayerCharacter = $Boss

func _ready() -> void:
	super._ready()
	player.intro_ended.connect(func() -> void: state = BossState.IDLE)
	player.health.dead.connect(func() -> void: state = BossState.NONE)
	
	boss.health.damaged.connect(func(amount: float, _hurt_time: float) -> void:
		Global.add_score(20 * int(amount))
		)
	boss.health.dead.connect(func() -> void:
		$HUD.boss_timer.stop()
		player.add_xp(xp_amount)
		Global.play_music(preload("res://Audio/Soundtrack/Victory.ogg"))
		save_player_state()
		player_dead(boss, data.boss_piece)
		Global.add_score(score_amount, 10000)
		)
		
	if data.boss_piece:
		boss.load_state(data.boss_piece.character_data)

func _process(delta: float) -> void:
	super._process(delta)

	if player.position.x > boss.position.x - 20:
		player.position.x = boss.position.x - 20
		player.velocity.x = 0
		
	if boss.position.x > camera.limit_right - 10:
		boss.position.x = camera.limit_right - 10
		boss.velocity.x = 0.0
	
	boss_ai()
	
func _on_hud_boss_timer_timeout() -> void:
	boss.save_state(data.boss_piece.character_data)
	
	Global.music_fade_out()
	await Global.fade_out_paused()
	
	Global.change_scene_node(Global.board)
	# true for ignore_boss_moves
	Global.board.returned(true)
	
#region Boss AI example
	
enum BossState {
	NONE,
	IDLE,
	MOVING,
}

var state: BossState = BossState.NONE
var time := 40
var attack_time := 0
var simple_attack_time := 0

func boss_ai() -> void:
	if state == BossState.NONE or boss.state.current == boss.State.DEAD:
		return
	
	time -= 1
	
	if boss.position.x < 50:
		boss.position.x = 50
		boss.velocity.x = 0
		state = BossState.IDLE
		
	if (boss.position.x - player.position.x) < 60:
		attack_time += 1
	elif (boss.position.x - player.position.x) < 100:
		simple_attack_time += 1
		
	if attack_time > 150 and boss.power.value > 3 * 8:
		attack_time = 0
		boss.simulate_input_press(PlayerCharacter.Inputs.START)
		
	if simple_attack_time > 100:
		simple_attack_time = 0
		spam_bullets()
	
	match state:
		BossState.IDLE:
			boss.inputs[boss.Inputs.XINPUT] = 0
			boss.inputs[boss.Inputs.YINPUT] = 0
			if time <= 0:
				state = BossState.MOVING
				time = 20
				
				boss.inputs[boss.Inputs.XINPUT] = randi_range(-1, 1)
				boss.inputs[boss.Inputs.YINPUT] = randi_range(-1, 1)
		BossState.MOVING:
			if boss.position.y > 160:
				boss.position.y = 160
				boss.velocity.y = 0
			if time <= 0:
				state = BossState.IDLE
				time = randi_range(30, 90)

func spam_bullets() -> void:
	boss.inputs_pressed[boss.Inputs.A] = true
	await get_tree().create_timer(1, false).timeout
	boss.inputs_pressed[boss.Inputs.A] = false
	
#endregion
