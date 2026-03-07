extends Node

@export var world_scene: PackedScene

# Enums machen den Code lesbar
enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER, GAME_FINISHED}
var current_state: GameState = GameState.MAIN_MENU
var current_world: Node = null

@onready var ui_layers = {
	GameState.MAIN_MENU: $UI/MainMenu,
	GameState.PLAYING: $UI/Button_Pause,
	GameState.PAUSED: $UI/PauseMenu,
	GameState.GAME_OVER: $UI/DeathMenu,
	GameState.GAME_FINISHED: $UI/FinishedMenu
}

func _ready() -> void:
	# Signale zentral verbinden
	ui_layers[GameState.MAIN_MENU].start_game.connect(_on_start_requested)
	ui_layers[GameState.PAUSED].restart.connect(_on_start_requested)
	ui_layers[GameState.GAME_OVER].restart.connect(_on_start_requested)
	
	ui_layers[GameState.PAUSED].resumed.connect(func(): change_state(GameState.PLAYING))
	ui_layers[GameState.PAUSED].quit_to_main.connect(func(): change_state(GameState.MAIN_MENU))
	ui_layers[GameState.GAME_OVER].quit_to_main.connect(func(): change_state(GameState.MAIN_MENU))
	ui_layers[GameState.GAME_FINISHED].quit_to_main.connect(func(): change_state(GameState.MAIN_MENU))
	
	ui_layers[GameState.PLAYING].pressed.connect(func(): change_state(GameState.PAUSED))
	
	# Initialer Zustand
	change_state(GameState.MAIN_MENU)

func change_state(new_state: GameState) -> void:
	current_state = new_state
	
	# 1. Sichtbarkeit steuern: Alle verstecken, nur das aktuelle zeigen
	for state in ui_layers:
		ui_layers[state].visible = (state == new_state)
	
	get_tree().paused = (GameState.PLAYING != new_state)
	
	# 2. Zustands-Logik (Was passiert beim Wechsel?)
	match new_state:
		GameState.MAIN_MENU:
			_clear_world()
		
		GameState.PLAYING:
			if current_world == null: # Falls wir vom Hauptmenü kommen
				_instantiate_world()
# --- Hilfsfunktionen ---

func _on_start_requested() -> void:
	_instantiate_world() # Welt neu bauen
	change_state(GameState.PLAYING)

func _instantiate_world() -> void:
	_clear_world()
	current_world = world_scene.instantiate()
	add_child(current_world)
	move_child(current_world, 0) 
	
	var player = current_world.find_child("Player")
	if player:
		player.died.connect(func(): change_state(GameState.GAME_OVER))
		player.finished.connect(func(): change_state(GameState.GAME_FINISHED))

func _clear_world() -> void:
	if current_world:
		current_world.queue_free()
		current_world = null
