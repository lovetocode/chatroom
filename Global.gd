extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_low_processor_usage_mode(true)
	OS.set_window_title("Chat Room")
