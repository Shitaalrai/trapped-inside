extends CanvasLayer

signal quit_to_menu

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var is_paused = get_tree().paused
	
	get_tree().paused = !is_paused
	visible = !is_paused

func _on_resume_pressed() -> void:
	$VBoxContainer/resume/click.play()
	resume()

func resume():
	get_tree().paused = false
	visible = false

func _on_restart_pressed() -> void:
	$VBoxContainer/restart/click.play()
	get_tree().paused = false  

func _on_quit_pressed() -> void:
	$VBoxContainer/quit/click.play()
	get_tree().paused = false
	quit_to_menu.emit()

func _on_resume_mouse_entered() -> void:
	$VBoxContainer/resume/hover.play()

func _on_restart_mouse_entered() -> void:
	$VBoxContainer/restart/hover2.play()

func _on_quit_mouse_entered() -> void:
	$VBoxContainer/quit/hover3.play()
