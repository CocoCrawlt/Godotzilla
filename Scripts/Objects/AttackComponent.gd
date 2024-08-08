extends Node2D

@export var attack_always := false
@export var default_attack_amount := 4.0
@export var objects_to_ignore: Array[Node2D]
@export var should_attack := true
@export var enemy := false

@onready var area_2d: Area2D = $Area2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

var attacked_bodies: Array[Node2D] = []

signal attacked(body: Node2D, amount: float)

func _ready() -> void:
	collision.shape = collision.shape.duplicate()
	collision.shape.size = Vector2.ZERO
	if not attack_always:
		attack_bodies()
		area_2d.body_entered.connect(_on_area_2d_body_entered)
	
func _process(_delta: float) -> void:
	if attack_always:
		attack_bodies()

func attack_bodies(amount: float = default_attack_amount) -> void:
	var bodies := area_2d.get_overlapping_bodies()
	for body in bodies:
		attack_body(body, amount)
			
func attack_body(body: Node2D, amount: float = default_attack_amount) -> void:
	if body == get_parent() or body in objects_to_ignore or not should_attack:
		return
	if body.has_node("HealthComponent") and (enemy != body.get_node("HealthComponent").enemy) \
		and body not in attacked_bodies:
			body.get_node("HealthComponent").damage(amount)
			attacked.emit(body, amount)
			attacked_bodies.append(body)

func set_collision(size: Vector2, offset: Vector2) -> void:
	collision.shape.size = size
	collision.position = offset
	
func start_attack(amount: float) -> void:
	attack_always = true
	should_attack = true
	default_attack_amount = amount
	attacked_bodies.clear()
	
func stop_attack() -> void:
	attack_always = false
	should_attack = false
	attacked_bodies.clear()
	collision.shape.size = Vector2.ZERO
	collision.position = Vector2.ZERO

func _on_area_2d_body_entered(body: Node2D) -> void:
	attack_body(body)
