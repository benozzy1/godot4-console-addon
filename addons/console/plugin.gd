@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Console", "res://addons/console/console.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("Console")
