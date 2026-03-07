extends Node

@export var world_scene: PackedScene

# Referenzen auf die wichtigsten Nodes (basierend auf deinem Szenenbaum)
@onready var main_menu = $UI/MainMenu
@onready var pause_menu = $UI/PauseMenu
@onready var death_menu = $UI/DeathMenu
@onready var pause_button = $UI/Button_Pause

var current_world: Node = null

func _ready() -> void:
	# 1. Signale verbinden
	main_menu.start_game.connect(_on_start_game)
	pause_menu.restart.connect(_on_start_game)
	pause_menu.resumed.connect(_on_resume_game)
	pause_menu.quit_to_main.connect(_on_back_to_main_menu)
	pause_button.pressed.connect(_on_pause_pressed)
	
	# 2. Start-Zustand festlegen
	_on_back_to_main_menu()

# --- Logik-Funktionen ---

func _on_start_game() -> void:
	# 1. Alte Welt löschen, falls sie existiert
	if current_world:
		current_world.queue_free()
	
	# 2. Neue Welt instanziieren
	current_world = world_scene.instantiate()
	add_child(current_world)

	# 3. Wichtig: Die Welt in der Hierarchie hinter die UI schieben
	move_child(current_world, 0) 

	# 4. Signale der NEUEN Welt verbinden
	# Wir suchen den Player in der neuen Welt
	var player = current_world.find_child("Player") # Stelle sicher, dass dein Player-Node so heißt
	if player:
		player.died.connect(_on_game_over)
	
	# Menü verstecken
	main_menu.hide()
	death_menu.hide()
	pause_menu.hide()
	pause_button.show()
	get_tree().paused = false # Spiel laufen lassen

func _on_game_over() -> void:
	get_tree().paused = true
	death_menu.show()
	pause_button.hide()

func _on_pause_pressed() -> void:
	# Spiel pausieren und Pausenmenü zeigen
	get_tree().paused = true
	pause_menu.show()
	pause_button.hide()

func _on_resume_game() -> void:
	# Pause aufheben
	pause_menu.hide()
	pause_button.show()
	get_tree().paused = false

func _on_back_to_main_menu() -> void:
	if current_world:
		current_world.queue_free()
		current_world = null
	
	# Alles verstecken außer das Hauptmenü
	pause_menu.hide()
	death_menu.hide()
	pause_button.hide()
	main_menu.show()
	get_tree().paused = true # Im Menü soll sich im Hintergrund nichts bewegen
