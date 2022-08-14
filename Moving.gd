extends Control

var following = false
var draging_start_pos = Vector2()
var currentScreenSize

func _on_Moving_gui_input(event):
	if (event is InputEventMouseButton):
		if (event.get_button_index() == 1):
			following = !following
			get_tree().get_root().get_node("Main").get_node("MovingBackground").visible = following
			draging_start_pos = get_local_mouse_position()

func _process(_delta):
	if (following):
		OS.set_window_position(OS.window_position + get_global_mouse_position() - draging_start_pos)

