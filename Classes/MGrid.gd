class_name MGrid
var w;
var h;
var bm = BitMap.new();
var cells = [];

func get(idx):
	if idx.y in range(h) and idx.x in range(w):
		return cells[idx.y][idx.x];
	else:
		return null;

func set(idx, value):
	cells[idx.y][idx.x] = value;

func _init(width, height):
	w = width;
	h = height;
	bm.create(Vector2(w, h));
	bm.set_bit_rect(Rect2(0, 0, w, h), true);
	# Create empty grid of cells
	for y in range(h):
		var row = [];
		for x in range(w):
			row.append(Cell.new(x, y, Cell.CellType.Plain));
		cells.append(row);
	refresh_neighbours();

func refresh_neighbours():
	# Configure cell neighbours
	for y in range(h):
		for x in range(w):
			if bm.get_bit(Vector2(x, y)):
				var c = get(Vector2(x, y));
				c.neighbours["North"] = (get(Vector2(x, y-1)) if y>0 and bm.get_bit(Vector2(x, y-1)) else null);
				c.neighbours["East"] = (get(Vector2(x+1, y)) if x<w-1 and bm.get_bit(Vector2(x+1, y)) else null);
				c.neighbours["South"] = (get(Vector2(x, y+1)) if y<h-1 and bm.get_bit(Vector2(x, y+1)) else null);
				c.neighbours["West"] = (get(Vector2(x-1, y)) if x>0 and bm.get_bit(Vector2(x-1, y)) else null);
			else:
				set(Vector2(x, y), null);

func cells():
	var list = [];
	for y in h:
		for x in w:
			if bm.get_bit(Vector2(x, y)):
				list.append(get(Vector2(x, y)));
	return list;

func random_cell():
	return cells()[randi() % cells().size()];

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

func random_dead_end():
	var cs = cells();
	cs.shuffle();
	for c in cs:
		if c.link_list().size() == 1:
			return c;

func has_keys():
	for c in cells():
		if c.type == Cell.CellType.Key:
			return true;
	return false;

func braid(infrequency):
	var list = cells();
	list.shuffle();
	for i in range(0, list.size()/infrequency):
		list[i].link_unlinked_neighbour();

func has_linked():
	for c in cells():
		if c.link_list().size() > 0:
			return true;
	return false;
