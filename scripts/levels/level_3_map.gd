extends Node2D

@onready var pause_menu = preload("res://UI/pause.tscn").instantiate()

func _ready() -> void:
	add_child(pause_menu)
	pause_menu.hide()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
