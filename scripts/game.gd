extends Node2D

@onready var coin_sound = $"/root/Main/Sounds/Coin"
@onready var score_label = $"/root/Main/HUD/UI/Score"
@onready var lives_label = $"/root/Main/HUD/UI/Lives"
@onready var gameover_label = $"/root/Main/HUD/UI/GameOver"

var score = 0
#var lives

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lives_label.text = "x%s" % Global.player_lives

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update the UI label
	score_label.text = str(score)

func add_score(value):
	score = score + value
	print("score = ", score)
	coin_sound.play()

func dec_lives():
	print("lives = ", Global.player_lives)
	Global.player_lives -= 1
	lives_label.text = "x%s" % Global.player_lives

func show_gameover():
	gameover_label.visible = true
