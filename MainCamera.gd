extends Camera2D

onready var followed = get_node("../Frog");
var decay = 0.8  # How quickly the shaking stops [0, 1].
var max_offset = Vector2(10, 5)  # Maximum hor/ver shake in pixels.
var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
onready var noise = OpenSimplexNoise.new()
var noise_y = 0

func _ready():
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0);

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	if Input.is_action_pressed("ui_ctrl"):
		position = lerp(position, followed.position+get_local_mouse_position(), 0.1);
	else:
		#if position.distance_to(followed.position) > 20:
		#	position = followed.position;
		#else:
			position = lerp(position, followed.position, 0.1);
