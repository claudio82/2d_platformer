extends RigidBody2D

#player scene ref
@onready var player = get_tree().root.get_node("Main/PlatformCharacter")
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectile_caller = $ProjectileCaller2D
# The projectiles will immediately expire upon collision with objects in this layer.
@export_flags_2d_physics var wall_layer: int

# Enemy stats
@export var speed = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const ATTACK_RADIUS = 260
const MIN_PIXEL_DIST = 300

var direction = Vector2(1,0) # current direction
var new_direction = Vector2(0,1) # next direction
var animation
var is_attacking = false
var shot = false
var last_x_dir = 0

# Direction timer
var rng = RandomNumberGenerator.new()
var timer = 0

func _ready():
	rng.randomize()
	$Timer.start()
	sprite_2d.animation_finished.connect(_on_animation_finished)
	sprite_2d.play("walk")

# Apply movement to the enemy
func _physics_process(delta):
	
	#velocity.x = lerp(velocity.x, direction.x * speed, 1.0)	
	var movement = lerp(direction, speed * direction * delta, 1.0)
	#movement.y = 0
	
	#velocity.x = movement.x
	#if !is_on_floor():
	#	movement.y = 0.1
	#else:
	#	movement.y = -1
	var collision = move_and_collide(movement,false,0.21)
	
	# if the enemy collides with other objects, turn them around and re-randomize the timer countdown
	if collision != null and collision.get_collider().name != "PlatformCharacter":
		# direction rotation
		direction = -direction  #rotated(rng.randf_range(PI/4, PI/2))
		$RayCast2D.position.x *= -1
		var isLeft = direction.x < 0
		sprite_2d.flip_h = isLeft
		# timer countdown random range
		timer = rng.randf_range(2, 5)
	# if they collide with the player 
	# trigger the timer's timeout() so that they can chase/move towards our player
	else:
		timer = 0
		if collision != null:
			print("Collided with ", collision.get_collider().name)
			player.hurt(10)
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider().name == "PlatformCharacter":
				$RayCast2D.position.x *= -1
			
	if !is_attacking:
		enemy_animations(direction)
		platform_edge()
	else:
		pass
		
		#if !shot:
		#	var player_distance = player.position - position
		#	var isLeft = player_distance.x < 0
		#	sprite_2d.flip_h = isLeft
		#	sprite_2d.play("attack")
		#	shot = true
		#	projectile_caller.request_projectile(0, position, player.position, null, Callable(), Callable(), custom_collision, proj_expired)

#func custom_collision(proj: Projectile2D, area_rid: RID, area: Node2D, area_shape_index: int, local_shape_index: int) -> void:
	# The "validate_collision" method makes sure that:
	# -> The projectile is not expired.
	# -> A lock projectile will only collide with its assigned target.
	# -> The projectile is not colliding with areas/bodies it already collided.
#	if not proj.validate_collision(area_rid, area):
#		return
	
	# Custom code snippet for immediate expiration on collision with "play"
	#if wall_layer:  #& area.collision_layer != 0:
#	if area is CharacterBody2D:
#		player.hurt(10)
#		proj.is_expired = true
#		return

#func proj_expired(proj: Projectile2D):
#	shot = false

# Animations
func enemy_animations(direction : Vector2):
	#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	if direction != Vector2.ZERO:
		# update our direction with the new_direction
		new_direction = direction
		var isLeft = direction.x < 0
		sprite_2d.flip_h = isLeft
		
		# play walk animation, because we are moving
		animation = "walk"
		sprite_2d.play(animation)
	else:
		var player_distance = player.position - position
		var isLeft = player_distance.x < 0
		sprite_2d.flip_h = isLeft
		
		# play idle animation, because we are still		
		animation = "idle"
		sprite_2d.play(animation)

func _on_animation_finished():
	if sprite_2d.animation == "attack":
		is_attacking = false

# syncs new_direction with the actual movement direction and is called whenever the enemy moves
func sync_new_direction():
	if direction != Vector2.ZERO:
		new_direction = direction.normalized()
		
		#if last_x_dir != 0:
		#	if sign(new_direction.x) != sign(last_x_dir):
		#		$RayCast2D.position *= -1
		#	last_x_dir = 0
	#else:
		#if last_x_dir != 0:
		#	var player_distance = player.position - position
		#	if sign(last_x_dir) != sign(player.position.x):
		#		$RayCast2D.position *= -1
		#	last_x_dir = 0

func _on_timer_timeout() -> void:
	# Calculate the distance of the player relative position to the enemy's position
	var player_distance = player.position - position
	# turn towards player so that it can attack if within radius
	if player_distance.length() <= ATTACK_RADIUS:
		new_direction = Vector2(player_distance.normalized().x, direction.y)
		sync_new_direction()
		
		#is_attacking = true
		
	# TODO: chase/move towards player to attack them
	elif player_distance.length() <= MIN_PIXEL_DIST and timer == 0:
		pass
		#direction.y = 1.0
		#last_x_dir = direction.x
		#direction = Vector2(player_distance.normalized().x, 0)
		 #if sign(direction.x) != sign(last_x_dir):
			#$RayCast2D.position *= -1
		#last_x_dir = 0

	# random roam
	elif timer == 0:
		# this will generate a random direction value
		#var random_direction = rng.randf()
		# This direction is obtained by random value.
		#if random_direction < 0.05:
		#	pass
			#last_x_dir = direction.x
			#enemy stops
			#direction = Vector2.ZERO
			
		#elif random_direction < 0.1:
		#	pass
			#last_x_dir = direction.x
			#enemy moves
			#direction = Vector2(1, 0)
		
		sync_new_direction()

func platform_edge():
	if not $RayCast2D.is_colliding():
		direction = -direction
		$RayCast2D.position.x *= -1
