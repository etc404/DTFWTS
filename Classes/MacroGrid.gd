class_name MacroGrid
var rooms = [];
var cells = [];
var w = 0;
var h = 0;
var bm = BitMap.new();

func _init(room_count):
	for i in range(room_count):
		absorb(RoomGrid.new(randi() % 10, "east", ["east"]), Vector2(randi()%20, randi()%20))

func absorb(new_room, offset):
	rooms.append(new_room);
	var new_grid = [];
	# Make new sizes
	var nw = w;
	var nh = h;
	if w < new_room.w + offset.x:
		nw = new_room.w + offset.x;
	if h < new_room.h + offset.y:
		nh = new_room.h + offset.y;
	# Create new empty grid
	for y in range(nh):
		var row = [];
		for x in range(nw):
			row.append(null);
		new_grid.append(row);
	# Fill empty grid with old grid contents
	for y in range(h):
		for x in range(w):
			new_grid[y][x] = get(Vector2(x, y));
	# Add new room contents
	for y in range(new_room.h):
		for x in range(new_room.w):
			new_grid[y+offset.y][x+offset.x] = new_room.contents.get(Vector2(x, y));
			bm.set_bit(Vector2(x+offset.x, y+offset.y), new_room.contents.bm.get_bit(Vector2(x, y)) or bm.get_bit(Vector2(x, y)));
	cells = new_grid;
	w = nw;
	h = nh;

func get(idx):
	if idx.y in range(h) and idx.x in range(w):
		return cells[idx.y][idx.x];
	else:
		return null;

func set(idx, value):
	cells[idx.y][idx.x] = value;

func refresh_neighbours():
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
