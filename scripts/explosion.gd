extends Node2D
@onready var explosion_duration: Timer = $explosion_duration
@onready var damage_timer: Timer = $damage_timer

var damage: int = 20
@export var caused_by: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player_bullet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_explosion_duration_timeout() -> void:
	queue_free()

func _on_damage_timer_timeout() -> void:
	damage = 0

func _on_damage_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("enemy_hurtbox"):
		area.take_damage(damage)
		print("damage dealt")
