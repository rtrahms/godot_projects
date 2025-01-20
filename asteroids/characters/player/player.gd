class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration = 10.0
@export var max_speed = 200.0
@export var rotation_speed = 250.0
@export var deceleration_rate = 0.5

@onready var muzzle = $Muzzle
@onready var sprite = $Ship

var laser_scene = preload("res://scenes/laser.tscn")

var shoot_cooldown = false
var shoot_cooldown_time_s = 0.25
var alive = true

func _process(delta):
	if Input.is_action_pressed("shoot"):
		if !shoot_cooldown:
			shoot_cooldown = true
			shoot_laser()
			await get_tree().create_timer(shoot_cooldown_time_s).timeout
			shoot_cooldown = false

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(0,Input.get_axis("move_forward","move_backward"))
	

	velocity += input_vector.rotated(rotation) * acceleration 
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	elif Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-1 * rotation_speed * delta))
		
	# if not actively driven, drop velocity slowly to zero
	if input_vector.y == 0:
		$ThrusterNoise.stop()
		velocity = velocity.move_toward(Vector2.ZERO, deceleration_rate)
	else:
		if !$ThrusterNoise.playing:
			$ThrusterNoise.play()
	move_and_slide()
	
	var screen = get_viewport_rect()
	
	# y position clip
	if global_position.y < 0:
		global_position.y = screen.size.y
	elif global_position.y > screen.size.y:
		global_position.y = 0
		
	# x position clip
	if global_position.x < 0:
		global_position.x = screen.size.x
	elif global_position.x > screen.size.x:
		global_position.x = 0
		

func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)
	
func die():
	if alive == true:
		alive = false
		emit_signal("died")
		sprite.visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		
func respawn(pos):
	if alive == false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		process_mode = Node.PROCESS_MODE_INHERIT
	
