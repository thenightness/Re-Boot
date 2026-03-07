extends Control

signal quit_to_main

func _on_button_quit_to_main_pressed() -> void:
	quit_to_main.emit()
