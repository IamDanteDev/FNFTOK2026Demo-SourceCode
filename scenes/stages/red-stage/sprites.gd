extends Node2D
@onready var spiny: Character = $"../Characters/spiny"
@onready var shyguy: Character = $"../Characters/shyguy"
@onready var goomba: Character = $"../Characters/goomba"
@onready var stage: Stage = $".."
@onready var keyprompt: RichTextLabel = $"../CanvasLayer/Label"

@onready var subtitle: RichTextLabel = $"../CanvasLayer/MarginContainer/Control/DialogueBox/MarginContainer/Text"
@onready var subtitle_box: MarginContainer = $"../CanvasLayer/MarginContainer"
var subtitle_tween


var player_strum
var enemy_strum
var health_bar
var time_bar
var info_bar

func _ready() -> void :
	if Conductor.cur_song == "Practice!":
		for i in [spiny, shyguy, goomba]:
			i.queue_free()
		stage.offset_amount = 0
		await get_tree().create_timer(0.025).timeout

		if Main.game_mode == "editor":
			return

		Conductor.song_position_updated.connect(_on_song_pos)

		player_strum = Event.hud.player_strum
		enemy_strum = Event.hud.enemy_strum
		health_bar = Event.hud.health_bar
		time_bar = Event.hud.time_bar
		info_bar = Event.hud.info_bar_container

		player_strum.modulate.a = 0
		enemy_strum.modulate.a = 0
		health_bar.modulate.a = 0
		time_bar.modulate.a = 0
		info_bar.modulate.a = 0

		subtitle_box.modulate.a = 0
		subtitle.modulate.a = 0
		keyprompt.modulate.a = 0

		stage.playstate.can_die = false

		get_dodge_key()
	else:
		subtitle_box.visible = false
		subtitle.visible = false
		keyprompt.visible = false

func display_subtitle(text):

	var t1 = create_tween()
	t1.tween_property(subtitle, "modulate:a", 0, 0.3)

	await t1.finished
	subtitle.text = text

	var t2 = create_tween()
	t2.tween_property(subtitle, "modulate:a", 1, 0.3).from(0)


func get_dodge_key():
	var event_first = InputMap.action_get_events("dodge").get(0)
	keyprompt.text = "[wave]PRESS [%s] TO DODGE" % [OS.get_keycode_string(event_first.physical_keycode).to_upper()]


func _on_song_pos(_pos, _last_pos):

	if Conductor.cur_song != "Practice!":
		return

	if song_pos_check(0.0):
		display_subtitle("Alright! Welcome to the BATTLE TUTORIAL.")
		var t = create_tween()
		t.tween_property(subtitle_box, "modulate:a", 1, 0.5)

	if song_pos_check(2.84):
		display_subtitle("Boyfriend! Some of your opponents will try to attack you. ")

	if song_pos_check(5.68):
		display_subtitle("Make sure to pay attention and dodge in time with the music!")

	if song_pos_check(9.79):
		display_subtitle("There are three types of attacks out there, each for different kinds of rhythms.")

	if song_pos_check(13.58):
		display_subtitle("First is the Three-Tick! I'm going to count \"3, 2, 1, GO!\" and you dodge on that \"GO!\".")

	if song_pos_check(20.21):
		display_subtitle("Let's try it!")
		var t = create_tween()
		t.tween_property(keyprompt, "modulate:a", 1, 0.5)



	if song_pos_check(22.42):
		display_subtitle("3, 2, 1, GO!")

	if song_pos_check(25.26):
		display_subtitle("Okay! Now without my counting!")

	if song_pos_check(30.63):
		display_subtitle("On different beats now!")

	if song_pos_check(40.74):
		var t = create_tween()
		t.tween_property(keyprompt, "modulate:a", 0, 0.5)
		display_subtitle("Now I'll teach you the Copy-Cues! I'm going to do a rhythm and you repeat it after two beats.")

	if song_pos_check(45.47):
		display_subtitle("So for example: \"Pow, pow, GO, GO!\" and you dodge on the \"GO!\"s again.")

	if song_pos_check(51.0):
		display_subtitle("Let's do it!")
		var t = create_tween()
		t.tween_property(keyprompt, "modulate:a", 1, 0.5)

	if song_pos_check(52.74):
		display_subtitle("Pow, pow, GO! GO!")

	if song_pos_check(55.89):
		display_subtitle("Keep that going!")

	if song_pos_check(60.95):
		display_subtitle("Now a little faster!")

	if song_pos_check(70.74):
		var t = create_tween()
		t.tween_property(keyprompt, "modulate:a", 0, 0.5)
		display_subtitle("Now for our last cue: One-Shots!")

	if song_pos_check(73.58):
		display_subtitle("These are very simple but they come at you FAST! It's only ONE beat and you dodge on the next!")

	if song_pos_check(78.63):
		display_subtitle("So like \"One, GO! One, GO!\".")

	if song_pos_check(82.42):
		display_subtitle("Don't worry, there is a little whistle to warn you when it's coming!")

	if song_pos_check(85.58):
		display_subtitle("Like this!")
		var t = create_tween()
		t.tween_property(keyprompt, "modulate:a", 1, 0.5)

	if song_pos_check(88.11):
		display_subtitle("One, GO! One, GO!")

	if song_pos_check(96.32):
		var t = create_tween()
		t.tween_property(keyprompt, "modulate:a", 0, 0.5)
		display_subtitle("Awesome! Now just to make sure you got it all, let's do a round with all three cues at once.")

	if song_pos_check(101.21):
		var t = create_tween()
		t.tween_property(player_strum, "modulate:a", 1, 0.5)
		display_subtitle("And no counting from me this time. Ready up, Boyfriend!")

	if song_pos_check(106.42):
		var t = create_tween()
		t.tween_property(subtitle_box, "modulate:a", 0, 0.5)


	if song_pos_check(126.32):
		display_subtitle("Punch-tastic job, Boyfriend! I think you're ready to face tough opponents now.")
		var t = create_tween()
		t.tween_property(subtitle_box, "modulate:a", 1, 0.5)



	if song_pos_check(131.68):
		display_subtitle("Best of luck, and come back for help if you ever need it!")


	if song_pos_check(134.84):
		display_subtitle("Buh-bye!")

	if song_pos_check(137.05):
		var t = create_tween()
		t.tween_property(subtitle_box, "modulate:a", 0, 0.5)

func song_pos_check(time: float):
	var pos = Conductor.song_position / 1000
	var last_pos = Conductor.last_song_position / 1000
	if pos >= time and last_pos <= time:
		return true
	else: return false
