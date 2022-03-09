extends Sprite

onready var _grid = get_node("../MazeGrid");
onready var _camera = get_node("../MainCamera");
var cell;
var time = 0;

func _ready():
	if _grid.w * _grid.h > 40:
		var end = _grid.end();
		position.x = end.col*16+10;
		position.y = end.row*16+12;
		cell = Vector2(end.col, end.row);
	else:
		position = Vector2(-200, -200);
		cell = Vector2(-1, -1);

func _process(delta):
	if _grid.w * _grid.h > 40:
		var distances = _grid.get(get_node("../Frog").cell).distances();
		var distance = distances.get(_grid.get(cell));
		if distance == 0 && get_node("../Frog")._is_ready():
			get_node("../Frog").doomed = true;
			_camera.add_trauma(200);
		if distance <= 2 and _grid.get(get_node("../Frog").cell).link_list().size() == 1:
			_camera.add_trauma(0.5);
		if distance <= 3:
			$Light2D.energy = 4;
		else:
			$Light2D.energy = 3;
		if distance < _grid.start().distances().max_distance()*0.75 and distance != 0:
			get_node("../MainCamera/AnimatedSprite").modulate.a = lerp(get_node("../MainCamera/AnimatedSprite").modulate.a, float(_grid.start().distances().max_distance()*0.75/distance)/2, 0.1);
			time += delta;
			var threshold = rand_range(1.0, 2.5)+(distances.get(_grid.end())*0.1)-(distance*0.1);
			if !_grid.has_keys():
				threshold *= 2;
				threshold /= 3;
			if time > threshold and get_node("../Frog")._is_ready() and _grid.ready:
				time -= threshold;
				var gridcell = distances.parent(_grid.get(cell));
				cell = Vector2(gridcell.col, gridcell.row)
				position.x = cell.x*16+10;
				position.y = cell.y*16+12;
				if distance < 7:
					_camera.add_trauma(1-(distance/10)-0.3);
		else:
			get_node("../MainCamera/AnimatedSprite").modulate.a = lerp(get_node("../MainCamera/AnimatedSprite").modulate.a/2, 0, 0.1);
	else:
		$Light2D.energy = 3;
		get_node("../MainCamera/AnimatedSprite").modulate.a = lerp(get_node("../MainCamera/AnimatedSprite").modulate.a/2, 0, 0.1);
