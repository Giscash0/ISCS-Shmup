
extends Node2D

@export var enemy_scene: PackedScene
var timer := 0.0
var spawn_interval := 2.0

func _ready() -> void:
	randomize()

func _physics_process(delta: float) -> void:
	# Press CTRL + Z to reset
	if Input.is_action_just_pressed("ui_undo"):
		get_tree().reload_current_scene()
		return

	timer += delta
	if timer >= spawn_interval:
		timer = 0
		spawn_interval = randf_range(0.5, 2.5)
		var viewport_size = get_viewport_rect().size
		var enemy = enemy_scene.instantiate()
		var side = randi() % 4
		var pos := Vector2.ZERO
		var dir := Vector2.ZERO
		
		match side:
			0: #top
				pos = Vector2(randf_range(30, viewport_size.x-30), -30)
				dir = Vector2.DOWN
			1: #bottom
				pos = Vector2(randf_range(30, viewport_size.x-30), viewport_size.y+40)
				dir = Vector2.UP
			2: #left
				pos = Vector2(-30, randf_range(40, viewport_size.y-30))
				dir = Vector2.RIGHT
			3: #right
				pos = Vector2(viewport_size.x+30, randf_range(40, viewport_size.y-30))
				dir = Vector2.LEFT
		enemy.global_position = pos
		enemy.direction = dir
		enemy.scale = Vector2(2.5, 2.5)
		add_child(enemy)
