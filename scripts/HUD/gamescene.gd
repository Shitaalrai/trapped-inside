extends Node2D

const GAME_OVER_SCENE: PackedScene = preload("res://UI/game_over.tscn")

@onready var HUD: Control = $UI/HUD
@onready var _player_data: PlayerDataService = get_node("/root/PlayerData")
var current_level: Node2D
var _is_loading: bool = false
var _game_over_ui: CanvasLayer


func _ready() -> void:
	_player_data.game_over.connect(_on_game_over)
	current_level = _find_level_node()
	_connect_player_to_hud()


func load_level(level_scene_path: String) -> void:
	_player_data.apply_room_transition()
	_load_level_async(level_scene_path)


func _load_level_async(level_scene_path: String) -> void:
	if _is_loading:
		return
	_is_loading = true

	if current_level and is_instance_valid(current_level):
		var old_level := current_level
		current_level = null
		old_level.queue_free()
		await old_level.tree_exited

	var level_scene := load(level_scene_path) as PackedScene
	if level_scene == null:
		push_error("Failed to load level scene: %s" % level_scene_path)
		_is_loading = false
		return

	current_level = level_scene.instantiate()
	add_child(current_level)
	move_child(current_level, 0)

	await get_tree().process_frame
	_connect_player_to_hud()
	_is_loading = false


func _find_level_node() -> Node2D:
	for child in get_children():
		if child == HUD.get_parent():
			continue
		if child is Node2D:
			return child
	return null


func _connect_player_to_hud() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player == null or not is_instance_valid(player):
		return
	if player.has_method("sync_from_player_data"):
		player.sync_from_player_data()
	if not player.update_hp_bar.is_connected(HUD.update_hp_bar):
		player.update_hp_bar.connect(HUD.update_hp_bar)


func _on_game_over() -> void:
	if _game_over_ui and is_instance_valid(_game_over_ui):
		return

	get_tree().paused = true
	_game_over_ui = GAME_OVER_SCENE.instantiate()
	$UI.add_child(_game_over_ui)
	_game_over_ui.return_to_menu_pressed.connect(_on_game_over_return_to_menu)


func _on_game_over_return_to_menu() -> void:
	get_tree().paused = false
	if _game_over_ui and is_instance_valid(_game_over_ui):
		_game_over_ui.queue_free()
		_game_over_ui = null

	var scene_handler: Node = get_tree().root.get_node_or_null("scenehandler")
	if scene_handler and scene_handler.has_method("go_to_main_menu"):
		scene_handler.go_to_main_menu()
