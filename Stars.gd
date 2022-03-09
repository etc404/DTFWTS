extends AnimatedSprite

func _process(delta):
	position = lerp(position, get_node("../../FloatingLights").position, 0.02);
