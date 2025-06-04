extends Node2D

@onready var coin_sound = $"/root/Main/Sounds/Coin"
@onready var score_label = $"/root/Main/HUD/UI/Score"

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update the UI label
	score_label.text = "Score: %s" % score
	
func add_score(value):
	score = score + value
	print("score = ", score)
	coin_sound.play()
