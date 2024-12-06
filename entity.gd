extends CharacterBody2D
class_name entity

var can_fire: bool = true
var damage_modifier: float = 1
var is_running: bool = false
var can_run: bool = true
var run_speed_modifier = 1.5
var using_stamina: bool = false
var regenerating_stamina: bool = true
var regenerating_hp: bool = true
var is_alive: bool = true
var enemy_attack_cooldown: bool = false
var enemy_inattack_range: bool = false
var invincible: bool = false
var can_dash: bool = true
var is_dashing: bool = false
var dash_speed_modifier = 5
var dash_direction: Vector2 = Vector2.ZERO

@export var speed: int  # speed in pixels/sec
@export var max_hp: int
var hp
@export var defense: int
@export var damage: int
@export var max_stamina: int
var stamina 

func _physics_process(delta: float) -> void:
	move_and_slide()
func _on_hp_regen_cooldown_timeout() -> void:
	regenerating_hp = true
