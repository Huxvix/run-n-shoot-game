extends CharacterBody2D
class_name enemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"."
@onready var enemyhealthbar: ProgressBar = $enemyhealthbar
@onready var hp_regen_cooldown: Timer = $hp_regen_cooldown
@onready var aggro_timer: Timer = $aggro_timer
@onready var aggro_area: Area2D = $aggro_area
@onready var attack_cooldown: Timer = $attack_cooldown
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var speed = 15  # speed in pixels/sec
@export var max_hp: int
var hp
@export var defense = 0
@export var damage = 10

var target: Node2D
var is_enemy: bool = true
var is_attacking: bool = false
var can_attack: bool = true
var player_in_range: bool = false
var looking_direction: String = "down"
var regenerating_hp: bool = true

func _ready() -> void:
	hp = max_hp
	enemyhealthbar.value = hp
	enemyhealthbar.max_value = max_hp
	enemyhealthbar.step = max_hp / 10000
	add_to_group("enemy")

func _process(delta):
	if regenerating_hp == true&&hp < max_hp:
		hp += 1
		update_health()
	if is_attacking:
		attack(target)

func _physics_process(delta):
	if player_in_range:
		follow_target(delta)
	update_animations()

func follow_target(delta):
	navigation_agent_2d.set_target_position(target.global_position)
	var next_position = navigation_agent_2d.get_next_path_position()
	if  is_attacking or navigation_agent_2d.is_target_reached():
		velocity = Vector2.ZERO
	else:
		var direction = (next_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

#update health function
func update_health():
	var healthbar = $enemyhealthbar
	healthbar.value = hp
	healthbar.max_value = max_hp 
	healthbar.step = max_hp / 10000
	print(hp)
	if hp == 0:
		die()

#healing
func take_heal(heal:int):
	hp += heal
func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && target == null:
		target = body
		player_in_range = true
		print("target identified")
		aggro_timer.stop()
	elif body == target:
		aggro_timer.stop()
		print("continuing chase")
func _on_aggro_area_body_exited(body: Node2D) -> void:
	if body == target:
		aggro_timer.start()
func unaggro():
	target = null
	player_in_range = false
	print("mustve been the wind")
	velocity = Vector2.ZERO
	if hp < max_hp:
		hp_regen_cooldown.start()
func _on_hp_regen_cooldown_timeout() -> void:
	regenerating_hp = true
func _on_aggro_timer_timeout() -> void:
	unaggro()
func _on_damage_zone_body_entered(body: Node2D) -> void:
	is_attacking = true
func attack(target):
	if can_attack == true:
		target.take_damage(damage)
		can_attack = false
		attack_cooldown.start()
func _on_damage_zone_body_exited(body: Node2D) -> void:
	is_attacking = false
func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func update_animations():
	if velocity.length() == 0:
# Idle animations
		if looking_direction == "up":
			animated_sprite.animation = "idle_up"
		elif looking_direction == "down":
			animated_sprite.animation = "idle_down"
		elif looking_direction == "left":
			animated_sprite.animation = "idle_left"
		elif looking_direction == "right":
			animated_sprite.animation = "idle_right"
	else:
# Walking animations
		if velocity.y < 0 and abs(velocity.x) < abs(velocity.y):
			animated_sprite.animation = "walk_up"
			looking_direction = "up"
		elif velocity.y > 0 and abs(velocity.x) < abs(velocity.y):
			animated_sprite.animation = "walk_down"
			looking_direction = "down"
		elif velocity.x < 0 and abs(velocity.x) > abs(velocity.y):
			animated_sprite.animation = "walk_left"
			looking_direction = "left"
		elif velocity.x > 0 and abs(velocity.x) > abs(velocity.y):
			animated_sprite.animation = "walk_right"
			looking_direction = "right"
func die():
	queue_free()


func _on_enemy_hurtbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
