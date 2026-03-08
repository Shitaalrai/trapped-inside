extends Node2D


var enemyList = [
	preload("res://scenes/enemies/enemy.tscn"),
	preload("res://scenes/enemies/enemy.tscn"),
]

const KEY_SCENE: PackedScene = preload("res://effects/key/key.tscn")

var has_key: bool = false
var key_spawned: bool = false
var key_node: Area2D

@onready var enemies_node: Node = $Enemies
@onready var door: Area2D = $Door

func _ready() -> void:
	for enemy in enemies_node.get_children():
		enemy.died.connect(_on_enemy_died)


var last_enemy_position: Vector2

func _on_enemy_died(pos: Vector2) -> void:
	last_enemy_position = pos

	if enemies_node.get_child_count() == 1:
		call_deferred("_spawn_key")



func _process(_delta: float) -> void:
	if key_spawned:
		return

	if enemies_node.get_child_count() == 0:
		_spawn_key()


func _spawn_key() -> void:
	key_spawned = true

	var key_instance := KEY_SCENE.instantiate() as Area2D
	key_instance.name = "Key"
	#key_instance.position = door.position + Vector2(-80, 0)
	key_instance.position = last_enemy_position
	key_instance.key_collected.connect(_on_key_collected)

	key_node = key_instance
	add_child(key_instance)


func _on_key_collected(_key: Area2D, _collector: Node2D) -> void:
	if has_key:
		return

	has_key = true



func _on_door_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if not has_key:
		return

	get_tree().call_deferred("change_scene_to_file" , "res://scenes/levels/level_3_map.tscn")
