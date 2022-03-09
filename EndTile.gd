extends Sprite

func _process(delta):
	if visible:
		if randi() % 20 == 0:
			visible = false;
	else:
		if randi() % 10 == 0:
			visible = true;
