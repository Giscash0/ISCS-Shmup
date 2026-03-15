extends CharacterBody2D

@export var speed := 80
@export var MAX_HP := 3
var hp := MAX_HP

@export var bullet_scene: PackedScene
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var explosion: CPUParticles2D = $explosion
@onready var body: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

var direction: Vector2 = Vector2.DOWN

var has_entered: bool = false

var is_shooting: bool = false
var has_shot: bool = false

var shoot_timer := 0.0

var cooldown_timer := 0.0
var next_shoot_time := 3.0
const MIN_NEXT_SHOOT_TIME := 1
const MAX_NEXT_SHOOT_TIME := 5

func _ready() -> void:
	randomize()
	anim.play("walk_" + get_direction_name(direction))
	next_shoot_time = randf_range(MIN_NEXT_SHOOT_TIME, MAX_NEXT_SHOOT_TIME)
	hp_bar.max_value = MAX_HP
	hp_bar.value = hp

func _physics_process(delta: float) -> void:
	# check if enemy has entered viewport
	if not has_entered and get_viewport_rect().has_point(global_position):
		has_entered = true

	if not is_shooting:
		velocity = direction * speed
		move_and_slide()
		
		cooldown_timer += delta
		
		if cooldown_timer >= next_shoot_time:
			is_shooting = true
			shoot_timer = 0.0
			anim.play("fire_" + get_direction_name(direction))
	else:
		shoot_timer += delta
		if shoot_timer >= 0.4 and not has_shot:
			has_shot = true
			var bullet = bullet_scene.instantiate()
			bullet.global_position = $BulletSpawnPoint.global_position
			bullet.add_to_group("enemy_bullet")
			bullet.color = Color("#c83c3e")
			bullet.direction = direction
			get_tree().current_scene.add_child(bullet)
		elif shoot_timer >= 0.8:
			is_shooting = false
			has_shot = false
			shoot_timer = 0.0
			
			cooldown_timer = 0.0
			next_shoot_time = randf_range(MIN_NEXT_SHOOT_TIME, MAX_NEXT_SHOOT_TIME)
			
			anim.play("walk_" + get_direction_name(direction))
	
	if has_entered and not get_viewport_rect().grow(100).has_point(global_position):
		queue_free()

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
		return ""

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.is_in_group("player_bullet"):
		hp -= 1
		hp_bar.value = hp
	
		if hp == 0:
			speed = 0
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			body.visible = false
			explosion.emitting = true
			await explosion.finished
			queue_free()
