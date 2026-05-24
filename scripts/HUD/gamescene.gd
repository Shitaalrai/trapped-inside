extends Node2D

@onready var HUD: Control = $UI/HUD

func _ready() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	player.update_hp_bar.connect(HUD.update_hp_bar)
	
