extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var splash_screen = $UI/SplashScreen
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPoint
@onready var player_spawn_area = $PlayerSpawnPoint/PlayerSpawnArea

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score = 0:
	set(value):
		score = value
		hud.score = score

var lives = 3:
	set(value):
		lives = value
		hud.init_lives(lives)
		
func _ready():
	splash_screen.visible = true
	game_over_screen.visible = false
	
	score = 0
	lives = 3
	
	player.connect("laser_shot",_on_player_laser_shot)
	player.connect("died",_on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
	
func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_player_died():
	$PlayerDiedSound.play()
	lives -= 1
	if lives <= 0:
		await get_tree().create_timer(2.0).timeout
		#get_tree().reload_current_scene()
		game_over_screen.visible = true
	else:
		# wait until spawn area is clear before spawning new player
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
			
		player.respawn(player_spawn_pos.global_position)
		
func _on_asteroid_exploded(pos, size, points):
	$AsteroidHitSound.play()
	score += points
	
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos,Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos,Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
	#print(score)
	
func spawn_asteroid(pos,size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded",_on_asteroid_exploded)
	#asteroids.add_child(a)
	asteroids.call_deferred("add_child", a)
	
