extends CharacterBody2D

signal update_hp_bar(hp_bar_value: int)

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 400
@export var attack_speed: float = 0.6
@export var attack_damage: int = 60

const INVULNERABILITY_TIME: float = 2.0

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO
var hitpoints: int = PlayerDataService.MAX_HP
var hitpoint_max: int = PlayerDataService.MAX_HP

var spawn_position: Vector2
var _is_respawning: bool = false
var _invulnerable: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var _player_data: PlayerDataService = get_node("/root/PlayerData")


func _ready() -> void:
	spawn_position = global_position
	hitpoint_max = _player_data.MAX_HP
	sync_from_player_data()
	animation_tree.active = true
	if not _player_data.hp_changed.is_connected(_on_player_data_hp_changed):
		_player_data.hp_changed.connect(_on_player_data_hp_changed)


func sync_from_player_data() -> void:
	hitpoints = _player_data.hitpoints
	hitpoint_max = _player_data.MAX_HP
	_emit_hp_bar()


func _emit_hp_bar() -> void:
	if hitpoint_max <= 0:
		return
	@warning_ignore("integer_division")
	update_hp_bar.emit(hitpoints * 100 / hitpoint_max)


func _unhandled_input(event: InputEvent) -> void:
	if state == State.DEAD or _is_respawning:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()


func _physics_process(_delta: float) -> void:
	if state == State.DEAD or _is_respawning:
		return
	if state != State.ATTACK:
		movement_loop()


func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	var motion: Vector2 = move_direction.normalized() * speed
	velocity = motion
	move_and_slide()

	if state in [State.IDLE, State.RUN]:
		if move_direction.x < 0:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0:
			$Sprite2D.flip_h = false

	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()


func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")


func attack() -> void:
	if state == State.ATTACK or _is_respawning:
		return

	state = State.ATTACK

	var mouse_pos: Vector2 = get_global_mouse_position()
	var attck_dir: Vector2 = (mouse_pos - global_position).normalized()
	$Sprite2D.flip_h = attck_dir.x < 0 and abs(attck_dir.x) >= abs(attck_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attck_dir)

	update_animation()

	await get_tree().create_timer(attack_speed).timeout
	if not is_instance_valid(self) or state == State.DEAD:
		return

	if move_direction != Vector2.ZERO:
		state = State.RUN
	else:
		state = State.IDLE

	update_animation()


func take_damage(damage_taken: int) -> void:
	if _invulnerable or state == State.DEAD or _is_respawning:
		return
	_player_data.take_damage(damage_taken)


func _on_player_data_hp_changed(new_hp: int, max_hp: int) -> void:
	hitpoints = new_hp
	hitpoint_max = max_hp
	_emit_hp_bar()
	if new_hp > 0 or state == State.DEAD or _is_respawning:
		return
	if _player_data.lives > 0:
		_handle_hp_depleted()
	else:
		_enter_game_over_state()


func _handle_hp_depleted() -> void:
	if _player_data.lose_life():
		respawn()
	else:
		_enter_game_over_state()


func respawn() -> void:
	_is_respawning = true
	_invulnerable = true
	state = State.IDLE
	velocity = Vector2.ZERO
	global_position = spawn_position
	sync_from_player_data()
	update_animation()
	await get_tree().create_timer(INVULNERABILITY_TIME).timeout
	if is_instance_valid(self):
		_invulnerable = false
		_is_respawning = false


func _enter_game_over_state() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.owner and area.owner.has_method("take_damage"):
		area.owner.take_damage(attack_damage)
