extends Node2D

func _ready():
	Conductor.beat_changed.connect(_on_beat)
	$"folded-toad".visible = true
	$toad.visible = false
	if Conductor.cur_song == "Practice!":
		$toad.visible = true
		$"folded-toad".visible = false

func _on_beat(beat):
	if int(beat) % 2 == 0:
		$toad.play("idle")
		$"folded-toad".play("idle")
