extends Control

signal resumed
signal quit_to_main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_resume_button_pressed():
	resumed.emit()
	
func _on_quit_to_main_pressed():
	quit_to_main.emit()
