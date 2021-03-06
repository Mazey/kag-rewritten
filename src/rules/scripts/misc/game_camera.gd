extends Camera2D

var target

func _process(_delta):
	if is_instance_valid(target):
		global_position = target.global_position

func _unhandled_input(event):
	if event.is_pressed() and event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom.y = clamp(zoom.y - 0.05, 0.25, 1)
			zoom.x = zoom.y
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom.y = clamp(zoom.y + 0.05, 0.25, 1)
			zoom.x = zoom.y
