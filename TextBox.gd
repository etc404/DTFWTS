extends Label

onready var _camera = get_node("../MainCameraIntroScene");
var time = 0;

func _ready():
	OS.window_fullscreen = true;

func _process(delta):
	time += delta;
	if text == "You'd Better.":
		_camera.add_trauma(delta);
		material = load("res://glitching.tres");
	if time > 3:
		text = "You'd Better.";
	if time > 7:
		get_tree().change_scene("res://Main.tscn")
