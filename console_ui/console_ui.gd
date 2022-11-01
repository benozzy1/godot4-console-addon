extends Control

var history: Array[String] = [""]
var history_index: int = 0: set = set_history_index

@onready var _scroll_container: ScrollContainer = %ScrollContainer
@onready var _text_label: RichTextLabel = %TextLabel
@onready var _prefix_label: Label = %PrefixLabel
@onready var _line_edit: LineEdit = %LineEdit


func _ready() -> void:
	Console.line_added.connect(_on_line_added)
	Console.command_executed.connect(_on_command_executed)
	
	_line_edit.text_changed.connect(_on_text_changed)
	_line_edit.text_submitted.connect(_on_text_submitted)
	
	Console.register_command(
		"clear",
		"Clears the console",
		func(args: Array = []) -> int:
			clear()
			return OK
	)
	
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
		if history_index > 0:
			history_index -= 1


func open() -> void:
	show()
	$AnimationPlayer.play("open")
	_line_edit.grab_focus.call_deferred()
	_line_edit.clear.call_deferred()


func close() -> void:
	hide()
	$AnimationPlayer.play("close")


func clear() -> void:
	_text_label.text = ""
	_scroll_container.scroll_vertical = _scroll_container.get_v_scroll_bar().min_value


func set_history_index(value: int) -> void:
	history_index = value
	
	_line_edit.text = history[value]
	_line_edit.set.call_deferred("caret_column", _line_edit.text.length())


func _on_text_changed(new_text: String) -> void:
	history[0] = new_text


func _on_text_submitted(new_text: String) -> void:
	if _prefix_label.visible:
		Console.write_line(_prefix_label.text + new_text)
	else:
		Console.write_line(new_text)
	_line_edit.clear()
	
	if new_text == "" or not _prefix_label.visible:
		return
	
	if history.has(new_text):
		history.erase(new_text)
	history.insert(1, new_text)
	
	history[0] = ""
	history_index = 0
	
	_prefix_label.hide()
	await Console.execute_command(new_text.strip_edges())
	_prefix_label.show()


func _on_line_added(text: String) -> void:
	_text_label.text += text
	await get_tree().create_timer(0.001).timeout
	_scroll_container.scroll_vertical = _scroll_container.get_v_scroll_bar().max_value


func _on_command_executed(command_name: String, result: int) -> void:
	if command_name == "":
		return
	
	if result == ERR_DOES_NOT_EXIST:
		Console.log_error("Command not found: %s" % command_name)
