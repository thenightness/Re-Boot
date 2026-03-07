extends CharacterBody2D

# 1. Define the possible states [cite: 62]
enum States {IDLE, WALK, AIR, WALL_HANG, LOCKED}

# 2. Track the current state with a setter for "enter/exit" logic [cite: 63, 77]
var state: States = States.IDLE: set = set_state 

const walkSpeed = 100.0
const pushSpeed = 200.0
const jump_velocity = -300.0

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_axis("ui_left", "ui_right")
	
	# --- PHYSICAL LOGIC (How we move in the current state) ---
	match state:
		States.IDLE, States.WALK:
			velocity.x = input_direction * walkSpeed
			if not is_on_floor(): 
				velocity += get_gravity() * delta
			if input_direction != 0:
				$AnimatedSprite2D.scale.x = input_direction
			
		States.AIR:
			velocity.x = input_direction * pushSpeed
			velocity += get_gravity() * delta
			if input_direction != 0:
				$AnimatedSprite2D.scale.x = input_direction
			
		States.WALL_HANG:
			# Gravity override logic from your original code
			if velocity.y > 0:
				velocity.y = 0
			else:
				velocity.y += 40

	# --- TRANSITION LOGIC (When to switch states) [cite: 71, 72] ---
	match state:
		States.IDLE, States.WALK:
			if Input.is_action_pressed("ui_up"):
				velocity.y = jump_velocity
				velocity.x = input_direction * pushSpeed
				state = States.AIR
			elif not is_on_floor():
				state = States.AIR
			elif is_equal_approx(input_direction, 0.0):
				state = States.IDLE
			else:
				state = States.WALK

		States.AIR:
			if is_on_floor():
				state = States.IDLE
			elif is_on_wall() and Input.is_action_pressed("ui_up"):
				state = States.WALL_HANG

		States.WALL_HANG:
			var wall_normal = get_wall_normal()
			# Wall Kick Logic
			if (wall_normal.x > 0 and input_direction > 0) or (wall_normal.x < 0 and input_direction < 0):
				velocity.x = wall_normal.x * pushSpeed
				velocity.y = jump_velocity
				state = States.AIR
			# Let go of wall
			elif not is_on_wall() or not Input.is_action_pressed("ui_up"):
				state = States.AIR
	move_and_slide()

# 3. Enter/Exit logic for animations or special values [cite: 78, 83]
func set_state(new_state: States) -> void:
	if state == new_state:
		return
	var previous_state := state
	state = new_state
	
	# Optional: Logic for when a state starts
	match state:
		States.IDLE:
			$AnimatedSprite2D.play("IDLE")
			print("Entered Idle")
			#$AnimationPlayer.play("IDLE")
		States.WALK:
			$AnimatedSprite2D.play("WALK")
		States.AIR:
			$AnimatedSprite2D.play("WALK")
			print("Entered Air")
		States.WALL_HANG:
			$AnimatedSprite2D.play("WALL_HANG")
			print("Started Wall Hanging")
		States.LOCKED:
			pass


func _on_pause_pressed() -> void:
	state = States.LOCKED
