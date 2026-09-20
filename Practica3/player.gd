extends Area2D

signal hit
signal health_changed(current_health)

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# --- Variables de Vidas e Invencibilidad ---
var max_health = 3
var health = 3
var is_invulnerable = false

# --- Variables de Dash ---
var dash_speed_multiplier = 2.5
var dash_duration = 0.2
var dash_cooldown = 1.5
var is_dashing = false
var can_dash = true

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# Activar Dash al presionar la acción si no está en enfriamiento
	if Input.is_action_just_pressed("dash") and can_dash and velocity.length() > 0:
		start_dash()

	# Calcular velocidad actual (normal o dash)
	var current_speed = speed
	if is_dashing:
		current_speed *= dash_speed_multiplier

	if velocity.length() > 0:
		velocity = velocity.normalized() * current_speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func start_dash():
	is_dashing = true
	can_dash = false
	is_invulnerable = true
	modulate.a = 0.5 # Efecto semitransparente durante el dash

	# Duración del dash
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	is_invulnerable = false
	modulate.a = 1.0

	# Enfriamiento (cooldown)
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func _on_body_entered(_body: Node2D) -> void:
	if is_invulnerable:
		return

	take_damage()

func take_damage():
	health -= 1
	health_changed.emit(health)

	if health <= 0:
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)
	else:
		# Parpadeo de invulnerabilidad temporal para no perder todas las vidas de golpe
		is_invulnerable = true
		for i in range(5):
			modulate.a = 0.3
			await get_tree().create_timer(0.1).timeout
			modulate.a = 1.0
			await get_tree().create_timer(0.1).timeout
		is_invulnerable = false

func start(pos):
	position = pos
	health = max_health
	is_invulnerable = false
	is_dashing = false
	can_dash = true
	modulate.a = 1.0
	health_changed.emit(health)
	show()
	$CollisionShape2D.disabled = false
