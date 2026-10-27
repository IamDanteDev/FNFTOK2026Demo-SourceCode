extends Node2D

@onready var player_strum: = $PlayerStrum
@onready var enemy_strum: = $EnemyStrum
@onready var health_bar = $HealthBar
@onready var time_bar = $TimeBar
@onready var info_bar_container = $HContainer
@onready var info_bar = $HContainer / InfoBar

@onready var countdown: Sprite2D = $Countdown

@onready var player_strum_pos = player_strum.position
@onready var enemy_strum_pos = enemy_strum.position

@onready var cue1_player = $Cues / Cue1 / Cue1Player
@onready var cue2_player = $Cues / Cue2 / Cue2Player
@onready var cue3_player = $Cues / Cue3 / Cue3Player

@onready var cue1 = $Cues / Cue1
@onready var cue2 = $Cues / Cue2
@onready var cue3 = $Cues / Cue3
@onready var combat_rating = $CombatRating

@onready var health_bar_pos = health_bar.position
@onready var info_bar_pos = info_bar_container.position

@onready var main_strum = player_strum


func _ready():
	Conductor.beat_changed.connect(_on_beat)

func _process(delta):
	scale = lerp(scale, Vector2.ONE, delta * 3)
	position = get_viewport_rect().size / 2


func setup_from_play_state(play_state):
	health_bar.update_from_character(play_state.stage.player_character, true)
	health_bar.update_from_character(play_state.stage.enemy_character)

func update_downscroll(downscroll):
	var multi = 1
	if downscroll:
		multi = -1

	_set_strum_downscroll(player_strum, downscroll, player_strum_pos)
	_set_strum_downscroll(enemy_strum, downscroll, enemy_strum_pos)

	health_bar.position.y = health_bar_pos.y * multi
	time_bar.position.y = - health_bar.position.y - 40 * multi
	info_bar_container.position.y = info_bar_pos.y * multi

	if downscroll:
		info_bar_container.position.y += 50

func update_middlescroll(strum, middlescroll):
	var other_strum = player_strum
	var old_position = enemy_strum_pos
	if strum == player_strum:
		other_strum = enemy_strum
		old_position = player_strum_pos

	if middlescroll:
		strum.position.x = 0 - (44 * strum.button_count)
		strum.visible = true
		other_strum.visible = false
	else:
		strum.position.x = old_position.x
		strum.visible = true
		other_strum.visible = true

func update_opponent_notes(strum, opponent_notes):
	var other_strum = player_strum
	if strum == player_strum:
		other_strum = enemy_strum

	if opponent_notes:
		other_strum.visible = false

func update_hud_visibility(hide_hud):
	if hide_hud:
		health_bar.visible = false
		info_bar_container.visible = false
		time_bar.visible = false
	else:
		health_bar.visible = true
		info_bar_container.visible = true
		if (Settings.load_visuals().time_bar == "disabled"):
			time_bar.visible = false
		else: time_bar.visible = true

func _set_strum_downscroll(strum, downscroll, default_pos):
	var multi = 1
	if downscroll:
		multi = -1

	strum.scroll_multi = multi
	strum.position.y = default_pos.y * multi


func _on_beat(beat):
	if beat < 0:
		return
