class_name Asteroid extends Area2D

signal exploded(position,size,points)

var movement_vector = Vector2(0,-1)
var speed = 50.0

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

enum AsteroidSize {LARGE, MEDIUM, SMALL}
var size = AsteroidSize.LARGE

var points : int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0

func _ready():
	rotation = randf_range(0,2*PI)
	#print(rotation_degrees)

	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50,100)
			sprite.texture = preload("res://assets/textures/rock_large.svg")
			cshape.shape = preload("res://resources/asteroid_cshape_large.tres")
		AsteroidSize.MEDIUM:
			speed = randf_range(100,150)
			sprite.texture = preload("res://assets/textures/rock_medium.svg")
			cshape.shape = preload("res://resources/asteroid_cshape_medium.tres")
		AsteroidSize.SMALL:
			speed = randf_range(100,200)
			sprite.texture = preload("res://assets/textures/rock_small.svg")
			cshape.shape = preload("res://resources/asteroid_cshape_small.tres")	
	#print(speed)
	
func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * delta * speed
	
	var screen = get_viewport_rect()
	
	var radius = cshape.shape.radius
	
	# y position clip
	if global_position.y + radius < 0:
		global_position.y = screen.size.y + radius
	elif global_position.y - radius > screen.size.y:
		global_position.y = -radius
		
	# x position clip
	if global_position.x + radius < 0:
		global_position.x = screen.size.x + radius
	elif global_position.x - radius > screen.size.x:
		global_position.x = -radius	

func explode():
	emit_signal("exploded",global_position,size,points)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body
		player.die()
