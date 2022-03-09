extends WorldEnvironment

func _process(_delta):
	if Input.is_key_pressed(16777237):
		self.environment.tonemap_exposure = 0.1;
	else:
		self.environment.tonemap_exposure = 0.01;
