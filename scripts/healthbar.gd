extends ProgressBar

@onready var player: CharacterBody2D = $"../../player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = player.hp 
	max_value = player.max_hp
	step = player.max_hp / 10000

func _process(delta: float) -> void:
	update_health()

func update_health():
	var healthbar = $healthbar
	value = player.hp
	max_value = player.max_hp
	step = player.max_hp / 10000
