# SoundManager.gd (Autoload)
extends Node

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_player = AudioStreamPlayer.new()

var button_click_sound = preload("res://assets/sounds/button_click.wav")

func _ready():
	add_child(music_player)
	add_child(sfx_player)
	music_player.bus = "Music"
	sfx_player.bus = "SFX"
	
	await get_tree().process_frame
	
	_connect_buttons_recursive(get_tree().root)
	
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	# Prüfen, ob der neue Node ein Button ist (BaseButton deckt Button, TextureButton etc. ab)
	if node is BaseButton:
		_connect_button_signal(node)

func _connect_buttons_recursive(node: Node):
	if node is BaseButton:
		_connect_button_signal(node)
		
	for child in node.get_children():
			_connect_buttons_recursive(child)

func _connect_button_signal(button: BaseButton):
# Verhindern, dass wir doppelt verbinden, falls Szenen gewechselt werden
	if not button.pressed.is_connected(_play_button_sound):
		button.pressed.connect(_play_button_sound)

func _play_button_sound():
	if button_click_sound:
		play_sfx(button_click_sound)

func play_music(stream: AudioStream):
	if music_player.stream == stream: return
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream):
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = stream
	p.bus = "SFX"
	p.play()
	p.finished.connect(p.queue_free)
