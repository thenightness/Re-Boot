extends CharacterBody2D

const walkSpeed = 100.0
const pushSpeed = 200.0
const jump_velocity = -300.0

func _physics_process(delta: float) -> void:
	var wall_normal = get_wall_normal()
	var input_direction := Input.get_axis("ui_left", "ui_right")
	# 1. Luft
	if not is_on_floor():
		# 2. Wall-Hang
		# Prüfen: Berühren wir eine Wand, sind in der Luft und halten "Jump"?
		if is_on_wall() and Input.is_action_pressed("ui_up"):
			# Fallen wird gestoppt
			if velocity.y > 0:
				velocity.y = 0
			else:
				velocity.y += 40
			# Prüfen, ob wir die Richtung weg von der Wand drücken
			# wall_normal.x ist 1 (Wand links) oder -1 (Wand rechts)
			if (wall_normal.x > 0 and input_direction > 0) or (wall_normal.x < 0 and input_direction < 0):
				# Wir geben dem Spieler einen Kick in beide Achsen
				velocity.x = wall_normal.x * pushSpeed
				velocity.y = jump_velocity
			#! Optional: Hier eine "Hang"-Animation abspielen
		else:
			velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity
		velocity.x = input_direction * pushSpeed
	elif not is_on_floor():
		# Get the input input_direction and handle the movement/deceleration.
		if input_direction:
			velocity.x = input_direction * pushSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, pushSpeed)
	else:
		# Get the input input_direction and handle the movement/deceleration.
		if input_direction:
			velocity.x = input_direction * walkSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, walkSpeed)

	move_and_slide()
