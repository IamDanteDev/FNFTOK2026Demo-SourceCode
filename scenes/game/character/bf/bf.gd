extends AnimatedSprite2D

func set_hole_punch(state):
	if state == true:
		animation = "scared"
		get_parent().frame = 1
	else:
		$Bf.animation = "mad"
		get_parent().frame = 0

func set_mood(mood: String = "happy"):
	animation = mood
