extends Control

@export var card_scene: PackedScene
@export var card_textures: Array[Texture2D] = []

@onready var grid: GridContainer = $GridContainer
@onready var flip_timer: Timer = $FlipTimer

var first_card: Card = null
var second_card: Card = null
var matched_pairs: int = 0
var total_pairs: int = 0
var can_click: bool = true

func _ready() -> void:
	flip_timer.timeout.connect(_on_flip_timer_timeout)
	start_game()

func start_game() -> void:
	for child in grid.get_children():
		child.queue_free()

	matched_pairs = 0
	total_pairs = card_textures.size()
	
	if total_pairs == 0:
		print("¡Advertencia: No has agregado texturas en el Inspector!")
		return

	# Crear dos cartas por cada imagen
	var deck: Array[int] = []
	for i in range(total_pairs):
		deck.append(i)
		deck.append(i)

	# Barajar aleatoriamente
	deck.shuffle()

	# Generar las cartas en la cuadrícula
	for id in deck:
		var card: Card = card_scene.instantiate()
		grid.add_child(card)
		card.setup(id, card_textures[id])
		card.card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card: Card) -> void:
	if not can_click:
		return

	card.flip()

	if first_card == null:
		first_card = card
	else:
		second_card = card
		can_click = false
		check_match()

func check_match() -> void:
	if first_card.card_id == second_card.card_id:
		first_card.match_found()
		second_card.match_found()
		matched_pairs += 1
		reset_turn()
		
		if matched_pairs == total_pairs:
			print("¡Felicidades, ganaste!")
	else:
		flip_timer.start()

func _on_flip_timer_timeout() -> void:
	first_card.hide_card()
	second_card.hide_card()
	reset_turn()

func reset_turn() -> void:
	first_card = null
	second_card = null
	can_click = true
