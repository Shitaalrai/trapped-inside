extends Control

@onready var _hearts: Array[TextureRect] = [%Heart1, %Heart2, %Heart3]
@onready var _player_data: PlayerDataService = get_node("/root/PlayerData")


func _ready() -> void:
	_player_data.lives_changed.connect(update_lives)
	_player_data.hp_changed.connect(_on_player_data_hp_changed)
	update_lives(_player_data.lives)
	_on_player_data_hp_changed(_player_data.hitpoints, _player_data.MAX_HP)


func update_hp_bar(new_value: int) -> void:
	%HitpointsBar.value = new_value


func update_lives(lives: int) -> void:
	for i in _hearts.size():
		_hearts[i].visible = i < lives


func _on_player_data_hp_changed(hitpoints: int, hitpoint_max: int) -> void:
	if hitpoint_max <= 0:
		return
	@warning_ignore("integer_division")
	update_hp_bar(hitpoints * 100 / hitpoint_max)
