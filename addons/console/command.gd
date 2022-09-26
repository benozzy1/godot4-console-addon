class_name Command

var description: String
var callable: Callable


func _init(desc: String, call: Callable) -> void:
	description = desc
	callable = call
