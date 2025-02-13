class_name HealthComponent
extends Node

## Maximum value of health the component should hold
@export var max_value := 10.0
@export var enemy := false
## The amount of time in seconds the component should be invincible after getting damaged
@export var invincibility_time_seconds := 0.0
## How many health points should be taken each frame
@export var health_speed := 1.0

## The current amount of health
var target_value := 0.0
## The amount of health that should be shown on screen
var value := 0.0:
	set(v):
		value = v
		value_changed.emit(value)
var died := false
var invincible := false

## The health amount that should be shown on screen has changed
signal value_changed(new_value: float)
signal damaged(amount: float, hurt_time: float)
signal healed(amount: float)
## Happens when the maximum amount of health changes
signal resized(new_amount: float)
signal dead

func _ready() -> void:
	set_value(max_value)
	
func _process(delta: float) -> void:
	value = move_toward(value, target_value, health_speed * 60 * delta)
	if value <= 0.0 and not died:
		died = true
		dead.emit()

func damage(amount: float, hurt_time: float = -1) -> void:
	if amount <= 0 or invincible or died \
		or (get_parent().has_method("is_hurtable") and not get_parent().is_hurtable()):
			return
	
	target_value = clampf(target_value - amount, 0.0, max_value)
	damaged.emit(amount, hurt_time)
	if invincibility_time_seconds > 0.0:
		invincible = true
		await get_tree().create_timer(invincibility_time_seconds, false).timeout
		invincible = false
		
func heal(amount: float) -> void:
	if amount <= 0 or target_value >= max_value or died:
		return
		
	if target_value + amount <= max_value:
		target_value += amount
		healed.emit(amount)
	else:
		var old_value := target_value
		target_value = max_value
		healed.emit(max_value - old_value)
		
func fill() -> void:
	set_value(max_value)
		
func resize(new_hp_amount: float) -> void:
	max_value = new_hp_amount
	resized.emit(new_hp_amount)
	
func resize_and_fill(new_hp_amount: float) -> void:
	resize(new_hp_amount)
	fill()
	
func set_value(new_value: float) -> void:
	target_value = minf(new_value, max_value)
	value = target_value
