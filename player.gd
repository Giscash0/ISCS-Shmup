extends CharacterBody2D

@export var speed := 150
@export var MAX_HP := 5
var hp := MAX_HP

@export var bullet_scene: PackedScene
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var explosion: CPUParticles2D = $explosion
@onready var body: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

var last_direction: String = "down"
var is_shooting: bool = false
var has_shot: bool = false
var shoot_cooldown := 0.8 # time it takes to do shooting animation
var shoot_timer := 0.0

func _ready() -> void:
	anim.play("idle_down")
	hp_bar.max_value = MAX_HP
	hp_bar.value = hp

func _physics_process(delta: float) -> void:
	var input_direction := Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_direction = input_direction.normalized()
	var direction = get_direction_name(input_direction)
	
	# movement
	if not is_shooting:
		velocity = input_direction * speed
		move_and_slide()
	
		# keep player inside viewport
		var viewport_size = get_viewport_rect().size
		position.x = clamp(position.x, 18, viewport_size.x - 18)
		position.y = clamp(position.y, 25, viewport_size.y - 25)
	
	# shooting
	if Input.is_action_just_pressed("ui_accept") and not is_shooting:
		is_shooting = true
		shoot_timer = 0.0
		anim.play("fire_" + direction)
	
	if is_shooting:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			is_shooting = false
			has_shot = false
		elif shoot_timer >= 0.4 and not has_shot:
			has_shot = true
			var bullet = bullet_scene.instantiate()
			bullet.global_position = $BulletSpawnPoint.global_position
			bullet.add_to_group("player_bullet")
			bullet.color = Color("#36eaee")
			match last_direction:
				"up": bullet.direction = Vector2.UP
				"down": bullet.direction = Vector2.DOWN
				"left": bullet.direction = Vector2.LEFT
				"right": bullet.direction = Vector2.RIGHT
				"up_left": bullet.direction = Vector2(-1,-1).normalized()
				"up_right": bullet.direction = Vector2(1,-1).normalized()
				"down_left": bullet.direction = Vector2(-1,1).normalized()
				"down_right": bullet.direction = Vector2(1,1).normalized()
			get_tree().current_scene.add_child(bullet)
	else:
		if input_direction != Vector2.ZERO:
			last_direction = direction
			anim.play("walk_" + direction)
		else:
			anim.play("idle_" + last_direction)

func get_direction_name(direction: Vector2) -> String:
	var x = direction.x
	var y = direction.y
	
	if y < 0:
		if x < 0:
			return "up_left"
		elif x > 0:
			return "up_right"
		else:
			return "up"
	elif y > 0:
		if x < 0:
			return "down_left"
		elif x > 0:
			return "down_right"
		else:
			return "down"
	else:
		if x < 0:
			return "left"
		elif x > 0:
			return "right"
		else:
			return last_direction

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") or area.is_in_group("enemy_bullet"):
		hp -= 1
		hp_bar.value = hp
	
		if hp == 0:
			speed = 0
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			body.visible = false
			explosion.emitting = true
			await explosion.finished
			queue_free()
