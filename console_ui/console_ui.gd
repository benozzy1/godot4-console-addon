extends Control

var history: Array[String] = []
var history_index: int = -1: set = set_history_index

@onready var _scroll_container: ScrollContainer = %ScrollContainer
@onready var _text_label: RichTextLabel = %TextLabel
@onready var _prefix_label: Label = %PrefixLabel
@onready var _line_edit: LineEdit = %LineEdit


func _ready() -> void:
	Console.line_added.connect(_on_line_added)
	Console.command_executed.connect(_on_command_executed)
	Console.register_command(
		"clear",
		"Clears the console",
		func(args: Array = []) -> int:
			clear()
			return OK
	)
	_line_edit.text_submitted.connect(_on_text_submitted)
	
	open()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_console"):
		if not visible:
			open()
	elif event.is_action_pressed("ui_cancel"):
		if visible:
			close()
	
	if event.is_action_pressed("ui_up"):
		if history_index < history.size() - 1:
			history_index += 1
	elif event.is_action_pressed("ui_down"):
		if history_index > -1:
			history_index -= 1


func open() -> void:
	show()
	$AnimationPlayer.play("open")
	_line_edit.grab_focus()
	_line_edit.clear.call_deferred()


func close() -> void:
	hide()
	$AnimationPlayer.play("close")


func clear() -> void:
	_text_label.text = ""
	_scroll_container.scroll_vertical = _scroll_container.get_v_scroll_bar().min_value


func set_history_index(value: int) -> void:
	history_index = value
	
	if value != -1:
		_line_edit.text = history[value]
		_line_edit.set.call_deferred("caret_column", _line_edit.text.length())
	else:
		_line_edit.text = ""


func _on_text_submitted(new_text: String) -> void:
	Console.write_line(_prefix_label.text + new_text)
	_line_edit.clear()
	
	if new_text == "":
		return
	
	if history.has(new_text):
		history.erase(new_text)
	history.push_front(new_text)
	history_index = -1
	await Console.execute_command(new_text.strip_edges())


func _on_line_added(text: String) -> void:
	_text_label.text += text
	await get_tree().create_timer(0.001).timeout
	_scroll_container.scroll_vertical = _scroll_container.get_v_scroll_bar().max_value


func _on_command_executed(command_name: String, result: int) -> void:
	if command_name == "":
		return
	
	if result == ERR_DOES_NOT_EXIST:
		Console.log_error("Command not found: %s" % command_name)
