extends ProgressBar

@onready var player: CharacterBody2D = $"../../player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = player.stamina 
	max_value = player.max_stamina
	step = player.max_stamina / 10000

func _process(delta: float) -> void:
	update_stamina()

func update_stamina():
	var stamina = $staminabar
	value = player.stamina
	max_value = player.max_stamina
	step = player.max_stamina / 10000
