extends CharacterBody2D

signal died
signal finished

# 1. Define the possible states [cite: 62]
enum States {IDLE, WALK, AIR, WALL_HANG}

# 2. Track the current state with a setter for "enter/exit" logic [cite: 63, 77]
var state: States = States.IDLE: set = set_state 

const walkSpeed = 100.0
const pushSpeed = 200.0
const jump_velocity = -300.0
var is_dead: bool = false
var is_finished: bool = false

func _ready() -> void:
	$Camera2D.make_current()

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
	
	# --- Spike-Kollisionsprüfung ---Tilemap
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		# Prüfen, ob wir eine TileMapLayer berührt haben
		if collider is TileMapLayer:
			# Die Position des Aufpralls leicht in das Tile hinein verschieben,
			# um sicherzugehen, dass wir das richtige Tile treffen.
			var collision_point = collision.get_position() - collision.get_normal()
			var tile_pos = collider.local_to_map(collider.to_local(collision_point))
			var tile_data = collider.get_cell_tile_data(tile_pos)
			# Prüfen, ob das Tile die "is_lethal" Eigenschaft hat
			if tile_data and tile_data.get_custom_data("is_lethal"):
				die()
				break

# 3. Enter/Exit logic for animations or special values [cite: 78, 83]
func set_state(new_state: States) -> void:
	if state == new_state:
		return
	state = new_state
	
	# Optional: Logic for when a state starts
	match state:
		States.IDLE:
			$AnimatedSprite2D.play("IDLE")
			print("Entered Idle")
		States.WALK:
			$AnimatedSprite2D.play("WALK")
		States.AIR:
			$AnimatedSprite2D.play("WALK")
			print("Entered Air")
		States.WALL_HANG:
			$AnimatedSprite2D.play("WALL_HANG")
			print("Started Wall Hanging")
			
func die():
	if is_dead: return # Wenn schon tot, dann nichts tun!
	is_dead = true
	died.emit()

func finish():
	if is_finished: return
	is_finished = true
	finished.emit()
