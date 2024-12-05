extends CharacterBody2D
class_name bullet

var pos : Vector2
var rota : float
var dir : float
var speed = 50
var range: int = 5000
var travelled = Vector2.ZERO
const EXPLOSION = preload("res://scenes/explosion.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = pos
	global_rotation = rota
	add_to_group("player_bullet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	travelled += velocity
	print(travelled.length())
	if travelled.length() >= range:
		explode()
	move_and_slide()

func explode():
	var explosion_instance = EXPLOSION.instantiate()
	explosion_instance.position = position
	var player = get_tree().get_nodes_in_group("player")[0]
	explosion_instance.caused_by = player
	get_tree().get_root().add_child(explosion_instance)
	queue_free()

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "enemy_hurtbox":
		print("hit enemy")
		explode()

func _on_area_2d_body_entered(body: Node2D) -> void:
		print("hit something")
		explode()
