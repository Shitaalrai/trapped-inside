extends Node2D

@onready var HUD: Control = $UI/HUD
var current_level: Node2D
var _is_loading: bool = false

func _ready() -> void:
	current_level = _find_level_node()
	_connect_player_to_hud()


func load_level(level_scene_path: String) -> void:
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
	if not player.update_hp_bar.is_connected(HUD.update_hp_bar):
		player.update_hp_bar.connect(HUD.update_hp_bar)
