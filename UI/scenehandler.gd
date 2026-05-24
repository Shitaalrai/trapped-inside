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

func new_game(origin: String) -> void:
	clear_scene()

	_player_data.reset_for_new_game()
	current_game = game_scene_packed.instantiate()
	add_child(current_game)

	# 🔥 connect pause menu HERE
	var pause_menu = current_game.find_child("pause", true, false)

	if pause_menu:
		pause_menu.quit_to_menu.connect(go_to_main_menu)
	else:
		print("Pause menu not found!")


func go_to_main_menu():
	clear_scene()
	load_main_menu("pause")


func clear_scene():
	for child in get_children():
		if child != self:
			child.queue_free()



func settings(_origin: String) -> void:
	pass


func exit_game(_origin: String) -> void:
	get_tree().quit()
