extends Node

@export var main_menu_packed: PackedScene
@export var game_scene_packed: PackedScene

var main_menu: Control
var current_game: Node = null

@onready var _player_data: PlayerDataService = get_node("/root/PlayerData")


func _ready() -> void:
	load_main_menu("start")


func load_main_menu(_origin: String) -> void:
	clear_scene()

	main_menu = main_menu_packed.instantiate()
	add_child(main_menu)

	main_menu.new_game_pressed.connect(new_game)
	main_menu.settings_pressed.connect(settings)
	main_menu.exit_pressed.connect(exit_game)

func new_game(_origin: String) -> void:
	call_deferred("_begin_game")


func restart_game() -> void:
	call_deferred("_begin_game")


func _begin_game() -> void:
	get_tree().paused = false
	current_game = null
	clear_scene()
	await get_tree().process_frame

	_player_data.reset_for_new_game()
	current_game = game_scene_packed.instantiate()
	add_child(current_game)
	_wire_pause_menu(current_game.find_child("pause", true, false))


func _wire_pause_menu(pause_menu: Node) -> void:
	if pause_menu == null:
		push_warning("Pause menu not found!")
		return

	var quit_cb := Callable(self, "go_to_main_menu")
	if pause_menu.has_signal("quit_to_menu") and not pause_menu.quit_to_menu.is_connected(quit_cb):
		pause_menu.quit_to_menu.connect(quit_cb)

	var restart_cb := Callable(self, "restart_game")
	if pause_menu.has_signal("restart_requested") and not pause_menu.restart_requested.is_connected(restart_cb):
		pause_menu.restart_requested.connect(restart_cb)


func go_to_main_menu():
	clear_scene()
	load_main_menu("pause")


func clear_scene() -> void:
	for child in get_children():
		if child != self:
			remove_child(child)
			child.queue_free()



func settings(_origin: String) -> void:
	pass


func exit_game(_origin: String) -> void:
	get_tree().quit()
