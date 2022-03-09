extends KinematicBody2D

var cell = Vector2();
var goal = Vector2();
onready var _sprite = $Frog_Sprite;
onready var _grid = get_node("../MazeGrid");

func update_index():
	cell = position/Vector2(16, 16)-Vector2(0.5, 0.5);
	cell.x = round(cell.x);
	cell.y = round(cell.y);

func _is_ready():
	return position == goal*Vector2(16, 16)+Vector2(8, 8);

func _process(delta):
	update_index();
	if position.distance_to(goal*Vector2(16, 16)+Vector2(8, 8)) < 0.5:
		position = goal*Vector2(16, 16)+Vector2(8, 8);
		_sprite.frame = 0;
	else:
		position = lerp(position, goal*Vector2(16, 16)+Vector2(8, 8), 0.4+delta);

func _ready():
	var start = _grid.start();
	cell = Vector2(start.col, start.row);
	position.x = start.col*16+8;
	position.y = start.row*16+8;
	goal = cell;

func _input(event):
	if _is_ready():
		if event.is_action_pressed("ui_right"):
			_sprite.rotation_degrees = 90;
			if cell.x < _grid.w:
				if _grid.get_cell(cell.x, cell.y)%5 in [0, 3, 4]:
					_sprite.frame = 1;
					goal.x += 1;
		elif event.is_action_pressed("ui_left"):
			_sprite.rotation_degrees = 270;
			if cell.x > 0:
				if _grid.get_cell(cell.x-1, cell.y)%5 in [0, 3, 4]:
					_sprite.frame = 1;
					goal.x -= 1
		elif event.is_action_pressed("ui_down"):
			_sprite.rotation_degrees = 180;
			if cell.y < _grid.h:
				if _grid.get_cell(cell.x, cell.y)%5 in [1, 3, 4]:
					_sprite.frame = 1;
					goal.y += 1
		elif event.is_action_pressed("ui_up"):
			_sprite.rotation_degrees = 0;
			if cell.y > 0:
				if _grid.get_cell(cell.x, cell.y-1)%5 in [1, 3, 4]:
					_sprite.frame = 1;
					goal.y -= 1
	if _grid.get(cell).type == Cell.CellType.Item:
		_grid.get(cell).mark(Cell.CellType.Plain);
		for child in _grid.get_children():
			if child.cell == cell:
				child.queue_free();
	if _grid.get(cell).type == Cell.CellType.Key:
		_grid.get(cell).mark(Cell.CellType.Plain);
		_grid.draw_grid();
	if _grid.get(cell).type == Cell.CellType.End and !_grid.has_keys():
		if randi() % 2 == 0:
			_grid.w+=1;
		else:
			_grid.h+=1;
		if randi() % 2 == 0:
			_grid.w+=1;
		else:
			_grid.h+=1;
		_grid._ready();
		_ready();
