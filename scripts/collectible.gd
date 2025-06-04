extends Area2D

@export var value = 1
@onready var game = $"/root/Main"
@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		' print("Coin collision detected.") '
		game.add_score(value)
		sprite.play("collected")
		sprite.animation_finished.connect(_on_animation_finished)
		

func _on_animation_finished():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
