extends Node

const DEBUG_HUD_SCENE = preload("res://scenes/game/hud/debug/debug.tscn")

var hud

func _ready():
	hud = DEBUG_HUD_SCENE.instantiate()
	add_child(hud)
