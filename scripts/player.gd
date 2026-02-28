extends CharacterBody2D


const movementSpeed = 130.0
const jump_velocity = -300.0
const wall_jump_push = 300.0


func _physics_process(delta: float) -> void:
	var wall_normal = get_wall_normal()
	var input_direction := Input.get_axis("ui_left", "ui_right")
	# 1. Standard-Schwerkraft anwenden, wenn man nicht am Boden ist
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
				velocity.x = wall_normal.x * wall_jump_push
				velocity.y = jump_velocity
			
			#! Optional: Hier eine "Hang"-Animation abspielen
		
		else:
			velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity
		
	# Get the input input_direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if input_direction:
		velocity.x = input_direction * movementSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, movementSpeed)

	move_and_slide()
