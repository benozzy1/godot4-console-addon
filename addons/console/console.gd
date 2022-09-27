extends Node

signal line_added(text: String)
signal command_registered(command_name: String)
signal command_unregistered(command_name: String)
signal command_executed(command_name: String, result: int)

const LOG_INFO_PREFIX: String = "[color=dark_gray][INFO][/color]"
const LOG_OK_PREFIX: String = "[color=green][OK][/color]"
const LOG_WARN_PREFIX: String = "[color=yellow][WARN][/color]"
const LOG_ERROR_PREFIX: String = "[color=red][ERROR][/color]"

var commands: Dictionary = {}


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


func register_command(command_name: String, description: String, callable: Callable) -> void:
	commands[command_name] = Command.new(description, callable)
	command_registered.emit(command_name)


func unregister_command(command_name: String) -> void:
	if commands.has(command_name):
		commands.erase(command_name)
		command_unregistered.emit(command_name)


func execute_command(command_name: String) -> int:
	var split_string: PackedStringArray = command_name.strip_edges().split(" ")
	var command: String = split_string[0].to_lower()
	var args: Array = split_string.remove_at(0)
	
	if command == "":
		return ERR_DOES_NOT_EXIST
	
	var err: int = OK
	if not has_command(command):
		printerr("Command not found: %s" % command)
		err = ERR_DOES_NOT_EXIST
	else:
		err = await get_command(command).callable.call(args)
	command_executed.emit(command, err)
	return err


func has_command(command_name: String) -> bool:
	return commands.has(command_name)


func get_command(command_name: String) -> Command:
	return commands[command_name]


func get_commands() -> Array[String]:
	var keys: Array[String] = commands.keys()
	keys.sort()
	return keys
