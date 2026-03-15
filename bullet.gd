extends Area2D

@export var speed := 400
@export var damage := 1
var direction: Vector2 = Vector2.ZERO
var exploded: bool = false
var color: Color = Color("#36eaee")

@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	particles.gravity = -direction * 600
	particles.color = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if exploded:
		return
	
	position += direction * speed * delta
	
	if not get_viewport_rect().grow(10).has_point(global_position):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if exploded:
		return
	
	if (is_in_group("player_bullet") and area.is_in_group("enemy")) or (is_in_group("enemy_bullet") and area.is_in_group("player")):
		exploded = true
		$".".scale = Vector2(2, 2)
		$CPUParticles2D.color = Color("#ffffff")
		speed = 0
		$CollisionShape2D.set_deferred("disabled", true)
		$CPUParticles2D.one_shot = true
		await $CPUParticles2D.finished
		queue_free()
