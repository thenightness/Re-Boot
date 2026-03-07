extends Control

signal quit_to_main
signal restart

func _on_quit_to_main_pressed() -> void:
	quit_to_main.emit()

func _on_restart_pressed() -> void:
	restart.emit()
