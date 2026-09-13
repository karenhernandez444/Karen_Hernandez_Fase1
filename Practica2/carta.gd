extends Button
class_name Card

signal card_clicked(card: Card)

@onready var card_icon: TextureRect = $Icono
@onready var back_icon: TextureRect = $reverso

var card_id: int = 0
var is_flipped: bool = false
var is_matched: bool = false

func setup(id: int, front_texture: Texture2D) -> void:
	card_id = id
	card_icon.texture = front_texture
	hide_card()

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if not is_flipped and not is_matched:
		card_clicked.emit(self)

func flip() -> void:
	is_flipped = true
	card_icon.visible = true
	back_icon.visible = false

func hide_card() -> void:
	is_flipped = false
	card_icon.visible = false
	back_icon.visible = true

func match_found() -> void:
	is_matched = true
	disabled = true
