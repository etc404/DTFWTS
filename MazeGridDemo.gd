extends TileMap

var w = 5;
var h = 5;

var cells = [];
var ready;
var bm = BitMap.new();

func prepare_grid():
	for y in range(h):
		var row = [];
		for x in range(w):
			row.append(Cell.new(x, y, Cell.CellType.Plain));
		cells.append(row);

func configure_cells():
	for y in range(h):
		for x in range(w):
			if bm.get_bit(Vector2(x, y)):
				var c = get(Vector2(x, y));
				c.neighbours["North"] = (get(Vector2(x, y-1)) if y>0 and bm.get_bit(Vector2(x, y-1)) else null);
				c.neighbours["East"] = (get(Vector2(x+1, y)) if x<w-1 and bm.get_bit(Vector2(x+1, y)) else null);
				c.neighbours["South"] = (get(Vector2(x, y+1)) if y<h-1 and bm.get_bit(Vector2(x, y+1)) else null);
				c.neighbours["West"] = (get(Vector2(x-1, y)) if x>0 and bm.get_bit(Vector2(x-1, y)) else null);
			else:
				var c = get(Vector2(x, y));
				c.neighbours["North"] = null;
				c.neighbours["East"] = null;
				c.neighbours["South"] = null;
				c.neighbours["West"] = null;

func cells():
	var r = []
	for row in cells:
		for c in row:
			r.append(c);
	return r;

func get(idx):
	if idx.y in range(0, h) and idx.x in range(0, w):
		return cells[idx.y][idx.x];
	else:
		return null;

func set(idx, value):
	cells[idx.y][idx.x] = value;

func apply_kruskals():
	var state = KruskalsState.new(self);
	var neighbours = state.neighbours;
	neighbours.shuffle();
	while neighbours.size() > 0:
		var left = neighbours[neighbours.size()-1][0];
		var right = neighbours[neighbours.size()-1][1];
		neighbours.remove(neighbours.size()-1);
		if state.can_merge(left, right):
			state.merge(left, right);

func fill_bitmap():
	bm.set_bit_rect(Rect2(0, 0, w, h), true);
	#bm.set_bit_rect(Rect2(2, 2, w-4, h-4), false);

func _ready():
	randomize();
	bm.create(Vector2(w, h));
	fill_bitmap();
	for child in get_children():
		child.queue_free();
	clear();
	ready = false;
	cells = [];
	randomize();
	prepare_grid();
	configure_cells();
	apply_kruskals();
	draw_endpoints();
	add_keys();
	#add_items();
	draw_grid();
	ready = true;

func draw_grid():
	for x in range(-1, w):
		for y in range(-1, h):
			var cell = get(Vector2(x, y));
			if cell != null and cell.nonnull_neighbours().size() > 0:
				var offset = 0;
				match cell.type:
					Cell.CellType.Start:
						offset = 10;
					Cell.CellType.End:
						if !has_keys():
							var scene = load("res://EndTile.tscn");
							var end = scene.instance();
							end.position = Vector2(cell.col*16+8, cell.row*16+8);
							add_child(end);
							offset = 15;
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
				if cell.type == Cell.CellType.Item:
					match cell.contents:
						0:
							var scene = load("res://GlowBerry.tscn");
							var glowberry = scene.instance();
							glowberry.position = Vector2(cell.col*16+8, cell.row*16+8);
							glowberry.cell = Vector2(cell.col, cell.row)
							add_child(glowberry);
			else:
				var East = 0;
				var South = 0;
				var Diag = 0;
				if get(Vector2(x+1, y)):
					East = get(Vector2(x+1, y)).nonnull_neighbours().size();
				if get(Vector2(x, y+1)):
					South = get(Vector2(x, y+1)).nonnull_neighbours().size();
				if get(Vector2(x+1, y+1)):
					Diag = get(Vector2(x+1, y+1)).nonnull_neighbours().size();
				if get(Vector2(x+1, y)) != null and East > 0: # Cell to The East
					if get(Vector2(x, y+1)) != null and South > 0: # Cell to The South
						set_cell(x, y, 7);
					else: # No Cell to The South
						set_cell(x, y, 6);
				else: # No Cell to The East
					if get(Vector2(x, y+1)) != null and South > 0: # Cell to The South
						set_cell(x, y, 5);
					else: # No Cell to The South
						if get(Vector2(x+1, y+1)) != null and Diag > 0:
							set_cell(x, y, 8);
						else:
							set_cell(x, y, 9);

func random_cell():
	return get(Vector2(randi() % w, randi() % h));

func start():
	for c in cells():
		if c.type == Cell.CellType.Start:
			return c;
	return null;

func end():
	for c in cells():
		if c.type == Cell.CellType.End:
			return c;
	return null;

func draw_endpoints():
	random_cell().distances().farthest().mark(Cell.CellType.Start);
	start().distances().farthest().mark(Cell.CellType.End);

func random_dead_end():
	var cs = cells();
	cs.shuffle();
	for c in cs:
		if c.link_list().size() == 1:
			return c;

func add_keys():
	var start = start();
	var end = end();
	while true:
		var deadend = random_dead_end();
		if deadend != start and deadend != end:
			deadend.mark(Cell.CellType.Key);
			return;

func has_keys():
	for c in cells():
		if c.type == Cell.CellType.Key:
			return true;
	return false;

func add_items():
	var cs = cells();
	cs.erase(start());
	cs.erase(end());
	cs.shuffle();
	cs[0].mark(Cell.CellType.Item, 0);
	cs.remove(0);
	for c in cs:
		if randi() % 40 == 0:
			c.mark(Cell.CellType.Item, 0);

func braid():
	var list = cells();
	list.shuffle();
	for i in range(0, list.size()/10):
		list[i].link_unlinked_neighbour();

func size():
	return w*h
