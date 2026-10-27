extends Node2D

var character_array = []

var koopa = 0

@export var stage: Stage

func _ready():
	Conductor.step_changed.connect(_on_step)
	character_array.append(get_children())

func un_set_singing(array: Array):
	if Main.game_mode != "editor":
		for i in array:
			get_child(i).disconnect_strum(stage.get_parent().hud.enemy_strum)

func set_singing(array: Array):
	if Main.game_mode != "editor":
		for i in array:

			get_child(i).register_strum(stage.get_parent().hud.enemy_strum)

func _on_step(step):

	match Conductor.cur_song:
		"Red Streamer Battle":
			match int(step) + 1:
				10:
					set_singing([2])
				206:
					un_set_singing([2])
					set_singing([1])
				265:
					un_set_singing([1])
					set_singing([0])
				304:
					un_set_singing([0])
					set_singing([2])
				320:
					un_set_singing([2])
					set_singing([1])
					set_singing([0])
				332:
					set_singing([2])
				438:
					un_set_singing([0])
					un_set_singing([1])
					set_singing([2])
				448:
					set_singing([1])
				456:
					set_singing([0])
				464:
					un_set_singing([2])
				521:
					un_set_singing([0])
					un_set_singing([1])
					set_singing([2])
				542:
					set_singing([0])
				560:
					un_set_singing([0])
					set_singing([1])
				592:
					un_set_singing([1])
				656:
					un_set_singing([2])
					set_singing([1])
				688:
					un_set_singing([1])
					set_singing([0])
				696:
					set_singing([1])
				704:
					set_singing([2])
				856:
					un_set_singing([0])
					un_set_singing([2])
					un_set_singing([1])
		"Autumn Mountain Battle":
			match int(step) + 1:
				8:
					set_singing([1])
				48:
					un_set_singing([1])
					set_singing([0])
				64:
					set_singing([1])
					set_singing([2])
				76:
					un_set_singing([1])
					un_set_singing([0])
				192:
					un_set_singing([2])
					set_singing([1])
				240:
					un_set_singing([1])
					set_singing([0])
				288:
					un_set_singing([0])
					set_singing([2])
				304:
					un_set_singing([2])
					set_singing([1])
				312:
					set_singing([0])
				320:
					un_set_singing([0])
					set_singing([2])
				332:
					set_singing([0])
				432:
					un_set_singing([0])
					un_set_singing([1])
				480:
					un_set_singing([2])
					set_singing([0])
				508:
					un_set_singing([0])
					set_singing([1])
				560:
					un_set_singing([1])
					set_singing([2])
				568:
					set_singing([1])
				576:
					set_singing([0])
				592:
					un_set_singing([2])
					un_set_singing([0])
					set_singing([1])
				624:
					un_set_singing([2])
					un_set_singing([1])
					set_singing([0])
				656:
					un_set_singing([0])
					un_set_singing([1])
					set_singing([2])
				702:
					set_singing([1])
				708:
					set_singing([0])
				848:
					un_set_singing([0])
					un_set_singing([1])
				896:
					set_singing([0])
					set_singing([1])
		"Event Battle":
			if (int(step) + 1) % 60 == 0:
				un_set_singing([0, 1, 2, 3, 4, 5])
				set_singing([randi_range(0, 5)])
		"R3TR0FUNK":
			if (int(step) + 1) % 60 == 0:
				var koopas = [0, 1, 2, 3]
				un_set_singing([0, 1, 2, 3])
				set_singing([koopas[koopa]])
				koopa += 1
				if koopa > 3:
					koopa = 0
		"Retribution":
			match int(step) + 1:
				8:

					set_singing([1])
