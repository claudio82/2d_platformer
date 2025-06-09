extends CharacterBody2D


@export var speed = 500
@export var jump_speed = -800
@export var acceleration = 15
@export var friction = 6

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound = $JumpSFX
@onready var hit_sound = $HitSFX
@onready var game = $"/root/Main"

var lastDir = 1
var can_move = true
var is_jumping = false
var is_dead = false

var max_health = 80.0
var health = 80.0

func _ready() -> void:
	sprite_2d.animation_finished.connect(_on_animation_finished)

func get_input(delta):
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
		
		if can_move:
			if is_on_floor():
				var isLeft = velocity.x < 0
				if isLeft:
					lastDir = -1
				else:
					lastDir = 1
				sprite_2d.flip_h = isLeft
				sprite_2d.play("walk")
		else:
			if sign(velocity.x) == lastDir:
				velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
			else:
				velocity.x = lerp(velocity.x, 0.0, 0.95)
			set_floor_char_props(delta)
	else:
		set_floor_char_props(delta)
			
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
		sprite_2d.play("jump")
		jump_sound.play()
		can_move = false

func set_floor_char_props(delta:float):
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.y = 0.0
		sprite_2d.play("idle")
		can_move = true

func _physics_process(delta):
	velocity.y += gravity * delta
	if !is_dead:
		get_input(delta)
		move_and_slide()
	
		if not is_on_floor() and velocity.y > 0:
			if sprite_2d.animation != "fall":
				sprite_2d.play("fall")
	#else:
	#	move_and_slide()

func hurt(damage):
	health -= damage
	
	# Child node health bar
	$HealthBar.change_value((health/max_health)*100)
	
	# This is for the canvaslayer health bar
	get_tree().call_group("health_bar", "change_value", (health/max_health)*100)
	
	hit_sound.play()
	
	if health <=0 and !is_dead:
		print ("Player DIED.")
		is_dead = true
		
		velocity.x = 0
		
		sprite_2d.play("die")
		
		game.dec_lives()

func _on_animation_finished():
	if sprite_2d.animation == "die":
		get_tree().paused = true
		#await get_tree().create_timer(1.0).timeout
		if Global.player_lives > 0:
			get_tree().paused = false
			get_tree().reload_current_scene()
		else:
			game.show_gameover()
