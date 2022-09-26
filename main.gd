extends Control


func _ready() -> void:
	Console.write_line("Welcome!")
	Console.write_line("This is a fully functioning console example.")
	Console.write_line("Created by benozzy.")
	Console.write_line("")
	
	Console.register_command(
		"echo",
		"Echoes your input",
		func(args: Array = []) -> int:
			if args.size() > 0:
				var result: String = ""
				for arg in args:
					result += arg + " "
				Console.write_line(result)
			return OK
	)
	Console.register_command(
		"help",
		"Returns a list of commands",
		func(args: Array = []) -> int:
			Console.write("[indent]")
			Console.write("[table=2]")
			for command in Console.get_commands():
				Console.write_line("[cell]%s			[/cell][cell]%s[/cell]" % [command, Console.get_command(command).description])
			Console.write("[/table]")
			Console.write_line("[/indent]")
			return OK
	)
	Console.register_command(
		"quit",
		"Quits application",
		func(args: Array = []) -> int:
			get_tree().quit()
			return OK
	)
