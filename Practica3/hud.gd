extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	

func show_game_over():
	$HealthLabel.hide()
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Monsters!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func update_health(health):
	$HealthLabel.show()
	var current_hp = max(0, health)
	# Muestra corazones rojos para las vidas vivas y negros/vacíos para las perdidas
	$HealthLabel.text = "❤️".repeat(current_hp) + "🖤".repeat(3 - current_hp)

func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
