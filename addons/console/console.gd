extends Node

signal line_added(text: String)

const LOG_INFO_PREFIX: String = "[color=dark_gray][INFO][/color]"
const LOG_OK_PREFIX: String = "[color=green][OK][/color]"
const LOG_WARN_PREFIX: String = "[color=yellow][WARN][/color]"
const LOG_ERROR_PREFIX: String = "[color=red][ERROR][/color]"

@onready var commands: Commands = Commands.new()


func _ready() -> void:
	commands.command_executed.connect(_on_command_executed)


func write(text: String) -> void:
	line_added.emit(text)


func write_line(text: String) -> void:
	write(text + "\n")


func log_info(text: String) -> void:
	write_line("%s %s" % [LOG_INFO_PREFIX, text])


func log_ok(text: String) -> void:
	write_line("%s %s" % [LOG_OK_PREFIX, text])


func log_warn(text: String) -> void:
	write_line("%s %s" % [LOG_WARN_PREFIX, text])


func log_error(text: String) -> void:
	write_line("%s %s" % [LOG_ERROR_PREFIX, text])


func register_command(command: String, description: String, callable: Callable) -> void:
	commands.register(command, description, callable)


func unregister_command(command: String) -> void:
	commands.unregister(command)


func execute_command(command: String) -> int:
	return await commands.execute(command)


func get_command(command: String) -> Command:
	return commands.get_command(command)


func get_commands() -> Array[String]:
	return commands.get_commands()


func _on_command_executed(command: String, result: int) -> void:
	if command == "":
		return
	
	if result == ERR_DOES_NOT_EXIST:
		log_error("Command not found: %s" % command)
