extends CharacterBody2D
var speed: int = 20  # speed in pixels/sec
var max_hp: int = 100
var max_stamina: int = 100
var defense: int = 0

var can_fire: bool = true
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
#set hp and stamina to max to start off
var hp = max_hp
var stamina = max_stamina

var bullet = preload("res://scenes/bullet.tscn")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stamina_regen_cooldown: Timer = $stamina_regen_cooldown
@onready var hp_regen_cooldown: Timer = $hp_regen_cooldown
@onready var hurt_timer: Timer = $hurt_timer
@onready var dash_cooldown: Timer = $dash_cooldown
@onready var dash_timer: Timer = $dash_timer

func _ready() -> void:
	add_to_group("player")

func _process(delta):
	if regenerating_stamina == true&&stamina < max_stamina:
		stamina += 0.25
	if regenerating_hp == true&&hp < max_hp:
		hp += max_hp/400

#KOŞMAYI VE DASHİ DÜZELT
func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	var speed_modifier
	var mouse_position = get_global_mouse_position()
	var mouse_angle = get_angle_to(mouse_position)
	if Input.is_action_just_pressed("dash") && stamina >= 20 && can_dash:
		dash_direction = (mouse_position - position).normalized()
		can_dash = false
		is_dashing = true
		stamina -= 20
		using_stamina = true
		regenerating_stamina = false
		stamina_regen_cooldown.stop()
		dash_cooldown.start()
		dash_timer.start()
		var dash_speed: int = speed * 5
		velocity += dash_direction * dash_speed
	if Input.is_action_pressed("shift")&& stamina > 0 && velocity.length() > 0 && can_run:
		is_running = true
		using_stamina = true
	else:
		is_running = false
		using_stamina = false
	update_animations(mouse_angle, direction)
	#check if still running and then calculate velocity
	if is_running:
		speed_modifier = run_speed_modifier
		stamina -= 0.5
		stamina_regen_cooldown.stop()
	if is_dashing:
		if direction == Vector2.ZERO:
			direction = dash_direction
		speed_modifier = dash_speed_modifier
		stamina_regen_cooldown.stop()
	if not is_running and not is_dashing:
		speed_modifier = 1
	velocity = direction * (speed * speed_modifier)
	move_and_slide()
	#start stamina regen upon not using stamina
	if using_stamina == false && stamina_regen_cooldown.time_left == 0 && regenerating_stamina == false:
		stamina_regen_cooldown.start()
	elif using_stamina:
		regenerating_stamina = false
	#check if holding lmb and if cooldown over to fire
	if (Input.is_action_pressed("lmb")&&can_fire==true):
		fire(mouse_position)
		can_fire = false
		$bullet_cooldown.start()
#firing
func fire(mouse_position):
	var bullet_instance = bullet.instantiate()
	bullet_instance.dir = get_angle_to(mouse_position)
	bullet_instance.pos = Vector2(position.x, position.y-3)
	get_tree().get_root().add_child(bullet_instance)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
#taking damage
func take_damage(damage:int):
	if invincible:
		return
	var real_damage: int
	real_damage = damage - defense
	if real_damage < 1: real_damage = 1
	hp -= real_damage
	regenerating_hp = false
	hp_regen_cooldown.stop()
	hurt_animation()
	if hp <= 0:
		hp = 0
		restart_game()

#healing
func take_heal(heal:int):
	hp += heal
func hurt_animation():
	animated_sprite.self_modulate = Color(1,0,0)
	hurt_timer.start()
func _on_hurt_timer_timeout() -> void:
	animated_sprite.self_modulate = Color(1,1,1)
#bullet cooldown timer
func _on_bullet_cooldown_timeout() -> void:
	can_fire = true
#stamina regen cooldown timer
func _on_stamina_regen_cooldown_timeout() -> void:
	regenerating_stamina = true
#hp regen cooldown timer
func _on_hp_regen_cooldown_timeout() -> void:
	regenerating_hp = true
func _on_dash_cooldown_timeout() -> void:
	can_dash = true
func _on_dash_timer_timeout() -> void:
	is_dashing = false
func restart_game():
	var current_scene = get_tree().current_scene.name
	get_tree().reload_current_scene()
func update_animations(mouse_angle, direction):
	#ANIMATIONS
#Idle
	if velocity.length() == 0:
		if mouse_angle<0.75&&mouse_angle>-0.75:
			animated_sprite.animation = "idle_right"
		elif mouse_angle>0.75&&mouse_angle<2.5:
			animated_sprite.animation = "idle_down"
		elif mouse_angle>-2.25&&mouse_angle<-0.75:
			animated_sprite.animation = "idle_up"
		else:
			animated_sprite.animation = "idle_left"
#Running
	elif is_running == true:
		if mouse_angle<0.75&&mouse_angle>-0.75:
			if direction.x > 0:
				animated_sprite.animation = "run_right"
			else:
				is_running = false
				using_stamina = false
				animated_sprite.animation = "walk_right"
		elif mouse_angle>0.75&&mouse_angle<2.5:
			if direction.y > 0:
				animated_sprite.animation = "run_down"
			else:
				is_running = false
				using_stamina = false
				animated_sprite.animation = "walk_down"
		elif mouse_angle>-2.25&&mouse_angle<-0.75:
			if direction.y < 0:
				animated_sprite.animation = "run_up"
			else:
				is_running = false
				using_stamina = false
				animated_sprite.animation = "walk_up"
		else:
			if direction.x < 0:
				animated_sprite.animation = "run_left"
			else:
				is_running = false
				using_stamina = false
				animated_sprite.animation = "walk_left"
#Walking
	elif is_running == false:
		if mouse_angle<0.75&&mouse_angle>-0.75:
			if direction.x < 0:
				animated_sprite.animation = "walk_right_reverse"
			else:
				animated_sprite.animation = "walk_right"
		elif mouse_angle>0.75&&mouse_angle<2.5:
			if direction.y < 0:
				animated_sprite.animation = "walk_down_reverse"
			else:
				animated_sprite.animation = "walk_down"
		elif mouse_angle>-2.25&&mouse_angle<-0.75:
			if direction.y > 0:
				animated_sprite.animation = "walk_up_reverse"
			else:
				animated_sprite.animation = "walk_up"
		else:
			if direction.x > 0:
				animated_sprite.animation = "walk_left_reverse"
			else:
				animated_sprite.animation = "walk_left"
