extends Node2D

# Node refs
@onready var spawned_enemies = $SpawnedEnemies
@onready var tilemap = get_tree().root.get_node("Main/TileMap/Layer1")

# Enemy stats
@export var max_enemies = 3
var enemy_count = 0 
var rng = RandomNumberGenerator.new()

func spawn_enemy():
	# print(tilemap.get_used_rect().size.x)
	if (tilemap.get_used_rect().size.x > 0 and tilemap.get_used_rect().size.y > 0):
		var x = 0
		var y = 0
		
		if enemy_count == 0:
			x = 712
			y = 94
		elif enemy_count == 1:
			x = 700
			y = 98
		elif enemy_count == 2:
			x = 688
			y = 90
			# Randomly select a position on the map
		var random_position = Vector2(x % tilemap.get_used_rect().size.x,
				y % tilemap.get_used_rect().size.y
		
			#rng.randi() % tilemap.get_used_rect().size.x,
			#rng.randi() % tilemap.get_used_rect().size.y
		)
		var enemy = Global.enemy_scene.instantiate()
		enemy.position = tilemap.map_to_local(random_position) + Vector2(32, 32)
		spawned_enemies.add_child(enemy)


func _on_timer_timeout() -> void:
	if enemy_count < max_enemies:
		spawn_enemy()
		enemy_count = enemy_count + 1
