extends Area2D
@onready var enemy: enemy = $".."

func _ready() -> void:
	add_to_group("enemy_hurtbox")
#taking damage
func take_damage(damage:int):
	var real_damage: int
	real_damage = damage - enemy.defense
	if real_damage < 1: real_damage = 1
	enemy.hp -= real_damage
	if enemy.hp < 0: enemy.hp = 0
	enemy.regenerating_hp = false
	enemy.hp_regen_cooldown.stop()
	enemy.update_health()
#upon taking damage, if aggro area HAS player, do not initialize the aggro timer
	if not enemy.aggro_area.get_overlapping_bodies().is_empty():
		enemy.aggro_timer.stop()
#otherwise if aggro area DOESNT have player and the enemy is hit, follow the player 'till aggro area is entered or aggro timer counts to 0
	else:  
		enemy._on_aggro_area_body_entered(get_tree().get_nodes_in_group("player")[0])
		enemy.aggro_timer.start()
