class_name Commands
extends Node

signal command_registered(command)
signal command_unregistered(command)
signal command_executed(command: String, result: int)

var commands_dict: Dictionary = {}


func register(command_name: String, description: String, callable: Callable) -> void:
	commands_dict[command_name] = Command.new(description, callable)
	command_registered.emit(command_name)


func unregister(command_name: String) -> void:
	if commands_dict.has(command_name):
		commands_dict.erase(command_name)
		command_unregistered.emit(command_name)


func execute(command_name: String) -> int:
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
	return commands_dict.has(command_name)


func get_command(command_name: String) -> Command:
	return commands_dict[command_name]


func get_commands() -> Array[String]:
	var keys: Array[String] = commands_dict.keys()
	keys.sort()
	return keys
