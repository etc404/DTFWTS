extends TileMap
var grid;

func _ready():
	for child in get_children():
		child.queue_free();
	grid = MacroGrid.new(3);
	var w = grid.w;
	var h = grid.h;
	clear();
	for x in range(-1, w):
		for y in range(-1, h):
			var cell = grid.get(Vector2(x, y));
			if cell != null and cell.nonnull_neighbours().size() > 0:
				var offset = 0;
				match cell.type:
					Cell.CellType.Start:
						offset = 10;
					Cell.CellType.End:
						offset = 15;
						var scene = load("res://EndTile.tscn");
						var end = scene.instance();
						end.position = Vector2(cell.col*16+8, cell.row*16+8);
						add_child(end);
					Cell.CellType.Key:
						offset = 20;
				if !cell.has_neighbour("South") or !cell.linked_to(cell.neighbours["South"]) or cell.neighbours["South"].nonnull_neighbours().size() == 0: # South Wall On
					if !cell.has_neighbour("East") or !cell.linked_to(cell.neighbours["East"]) or cell.neighbours["East"].nonnull_neighbours().size() == 0: # East Wall On
						set_cell(x, y, 2+offset);
					else: # East Wall Off
						set_cell(x, y, 0+offset);
				else: # South Wall Off
					if !cell.has_neighbour("East") or !cell.linked_to(cell.neighbours["East"]) or cell.neighbours["East"].nonnull_neighbours().size() == 0: # East Wall On
						set_cell(x, y, 1+offset);
					else: # East Wall Off
						if cell.neighbours["East"].linked_to(cell.neighbours["East"].neighbours["South"]) and cell.neighbours["South"].linked_to(cell.neighbours["South"].neighbours["East"]):
							set_cell(x, y, 4+offset);
						else:
							set_cell(x, y, 3+offset);
			else:
				var East = 0;
				var South = 0;
				var Diag = 0;
				if grid.get(Vector2(x+1, y)):
					East = grid.get(Vector2(x+1, y)).nonnull_neighbours().size();
				if grid.get(Vector2(x, y+1)):
					South = grid.get(Vector2(x, y+1)).nonnull_neighbours().size();
				if grid.get(Vector2(x+1, y+1)):
					Diag = grid.get(Vector2(x+1, y+1)).nonnull_neighbours().size();
				if grid.get(Vector2(x+1, y)) != null and East > 0: # Cell to The East
					if grid.get(Vector2(x, y+1)) != null and South > 0: # Cell to The South
						set_cell(x, y, 7);
					else: # No Cell to The South
						set_cell(x, y, 6);
				else: # No Cell to The East
					if grid.get(Vector2(x, y+1)) != null and South > 0: # Cell to The South
						set_cell(x, y, 5);
					else: # No Cell to The South
						if grid.get(Vector2(x+1, y+1)) != null and Diag > 0:
							set_cell(x, y, 8);
						else:
							set_cell(x, y, 9);

func _input(event):
	if event.as_text() in ["W", "A", "S", "D", "Minus", "Equal", "Enter", "Space"]:
		match event.as_text():
			"W":
				position.y += 5;
			"A":
				position.x += 5;
			"S":
				position.y -= 5;
			"D":
				position.x -= 5;
			"Minus":
				get_node("../Camera2D").zoom += Vector2(0.05, 0.05);
			"Equal":
				get_node("../Camera2D").zoom -= Vector2(0.05, 0.05);
			"Space":
				_ready();
