class_name RoomGrid

var w;
var h;
var id;
var contents;
var exits = {};

func _init(idnum, dir, ex, l=null):
	randomize();
	id = idnum;
	match id:
		0: # Corridor Room
			generate_corridor(ex, l);
			print("Corridor generated.");
			apply_recursive_backtracker();
			contents.braid(10);
		1: # Spawn Room
			generate_spawn(dir, ex);
			print("Spawn generated.");
			apply_kruskals();
			contents.braid(10);
			contents.get(Vector2(w/2, h/2)).mark(Cell.CellType.Start);
		2: # End Room
			generate_end(dir, ex);
			print("End generated.");
			apply_kruskals();
			contents.braid(10);
			contents.get(Vector2(w/2, h/2)).mark(Cell.CellType.End);
			contents.random_dead_end().mark(Cell.CellType.Star);
		3: # Star Room
			generate_star(dir, ex);
			print("Star room generated.")
			apply_kruskals();
			contents.braid(10);
			contents.get(Vector2(w/2, h/2)).mark(Cell.CellType.Star);
		4: # Key Room
			generate_key(dir, ex);
			print("Key room generated.")
			apply_kruskals();
			contents.braid(10);
			contents.get(Vector2(w/2, h/2)).mark(Cell.CellType.Key);
		5: # General Room
			generate_general(dir, ex);
			print("General room generated.")
			apply_kruskals();
			contents.braid(10);
		6: # Large Room
			generate_large(dir, ex);
			print("Large room generated.")
			apply_kruskals();
			contents.braid(12);
		7: # Library Room
			generate_library(dir, ex);
			print("Library generated.")
		8: # Dead End Room
			generate_deadend(dir, ex);
			print("Dead end generated.")
			apply_prims();
		9: # Item Room
			generate_item(dir, ex);
			print("Item room generated.")
			apply_kruskals();
			contents.braid(10);
			contents.get(Vector2(w/2, h/2)).mark(Cell.CellType.Item);
	contents.refresh_neighbours();

func apply_kruskals():
	contents.refresh_neighbours();
	var state = KruskalsState.new(contents);
	var neighbours = state.neighbours;
	neighbours.shuffle();
	while neighbours.size() > 0:
		var left = neighbours[neighbours.size()-1][0];
		var right = neighbours[neighbours.size()-1][1];
		neighbours.remove(neighbours.size()-1);
		if state.can_merge(left, right):
			state.merge(left, right);

func apply_prims():
	contents.refresh_neighbours();
	while !contents.has_linked():
		var active = [];
		active.append(contents.random_cell());
		var costs = {};
		for cell in contents.cells():
			costs[cell] = randi() % 100;
		while active.size() > 0:
			var cell = active[0];
			for key in active:
				if costs[key] < costs[cell]:
					cell = key;
			var available_neighbours = cell.available_neighbours();
			if available_neighbours.size() > 0:
				var neighbour = available_neighbours[0];
				for key in available_neighbours:
					if costs[key] < costs[cell]:
						neighbour = key;
				cell.link(neighbour);
				active.append(neighbour);
			else:
				active.erase(cell);

func apply_recursive_backtracker():
	contents.refresh_neighbours();
	while !contents.has_linked():
		var stack = [contents.random_cell()];
		while stack.size() > 0:
			var current = stack[-1];
			var neighbours = current.available_neighbours();
			if neighbours.size() == 0:
				stack.pop_back();
			else:
				neighbours.shuffle();
				var neighbour = neighbours[-1];
				current.link(neighbour);
				stack.append(neighbour);

func generate_corridor(ex, l=null):
	if ex.size() in [1, 2]:
		if ex[0] in ["west", "east"]:
			h = randi() % 3 + 3;
			if l != null:
				w = l;
			else:
				w = int(h*(randf()+2));
			contents = MGrid.new(w, h);
			if randi() % 2 == 0:
				for col in range(1, w-1):
					contents.bm.set_bit(Vector2(col, h/2), false);
			if "west" in ex:
				exits["west"] = Vector2(0, h/2);
			if "east" in ex:
				exits["east"] = Vector2(w-1, h/2);
		else:
			w = randi() % 3 + 3;
			if l != null:
				h = l;
			else:
				h = int(w*(randf()+2));
			contents = MGrid.new(w, h);
			if randi() % 2 == 0:
				for row in range(1, h-1):
					contents.bm.set_bit(Vector2(w/2, row), false);
			if "north" in ex:
				exits["north"] = Vector2(w/2, 0);
			if "south" in ex:
				exits["south"] = Vector2(w/2, h-1);

func circle(center):
	for x in [center.x-1, center.x, center.x+1]:
		for y in [center.y-1, center.y, center.y+1]:
			if Vector2(x, y) != center:
				contents.bm.set_bit(Vector2(x, y), false);

func outer_circle(center):
	for x in [center.x-1, center.x, center.x+1]:
		contents.bm.set_bit(Vector2(x, center.y-2), false);
		contents.bm.set_bit(Vector2(x, center.y+2), false);
	for y in [center.y-1, center.y, center.y+1]:
		contents.bm.set_bit(Vector2(center.x-2, y), false);
		contents.bm.set_bit(Vector2(center.x+2, y), false);

func generate_spawn(dir, ex):
	w = [5, 7, 9][randi() % 3];
	h = w;
	contents = MGrid.new(w, h);
	circle(Vector2(w/2, h/2));
	if w > 5:
		outer_circle(Vector2(w/2, h/2));
		contents.bm.set_bit(Vector2(0, 0), false);
		contents.bm.set_bit(Vector2(w-1, 0), false);
		contents.bm.set_bit(Vector2(0, h-1), false);
		contents.bm.set_bit(Vector2(w-1, h-1), false);
	match dir:
		"north":
			for row in range(0, h/2):
				contents.bm.set_bit(Vector2(w/2, row), true);
		"east":
			for col in range(w/2, w):
				contents.bm.set_bit(Vector2(col, h/2), true);
		"south":
			for row in range(h/2, h):
				contents.bm.set_bit(Vector2(w/2, row), true);
		"west":
			for col in range(0, w/2):
				contents.bm.set_bit(Vector2(col, h/2), true);
	for e in ex:
		match e:
			"north":
				exits["north"] = Vector2(w/2, 0);
			"east":
				exits["east"] = Vector2(w-1, h/2);
			"south":
				exits["south"] = Vector2(w/2, h-1);
			"west":
				exits["west"] = Vector2(0, h/2);

func generate_end(dir, ex):
	generate_spawn(dir, ex);
	match dir:
		"north": # Quad I or II
			if randi() % 2 == 0:
				for row in range(w/2+1, w):
					for col in range(0, h/2):
						contents.bm.set_bit(Vector2(row, col), false);
			else:
				for row in range(0, w/2):
					for col in range(0, h/2):
						contents.bm.set_bit(Vector2(row, col), false);
		"east": # Quad I or IV
			if randi() % 2 == 0:
				for row in range(w/2+1, w):
					for col in range(0, h/2):
						contents.bm.set_bit(Vector2(row, col), false);
			else:
				for row in range(w/2+1, w):
					for col in range(h/2+1, h):
						contents.bm.set_bit(Vector2(row, col), false);
		"south": # Quad III or IV
			if randi() % 2 == 0:
				for row in range(0, w/2):
					for col in range(h/2+1, h):
						contents.bm.set_bit(Vector2(row, col), false);
			else:
				for row in range(w/2+1, w):
					for col in range(h/2+1, h):
						contents.bm.set_bit(Vector2(row, col), false);
		"west": # Quad II or III
			if randi() % 2 == 0:
				for row in range(0, w/2):
					for col in range(0, h/2):
						contents.bm.set_bit(Vector2(row, col), false);
			else:
				for row in range(0, w/2):
					for col in range(h/2+1, h):
						contents.bm.set_bit(Vector2(row, col), false);

func generate_star(dir, ex):
	generate_spawn(dir, ex);
	if randi() % 2 == 0: # Quad I and III
		for row in range(w/2+1, w):
			for col in range(0, h/2):
				contents.bm.set_bit(Vector2(row, col), false);
		for row in range(0, w/2):
			for col in range(h/2+1, h):
				contents.bm.set_bit(Vector2(row, col), false);
	else: # Quad II and IV
		for row in range(0, w/2):
			for col in range(0, h/2):
				contents.bm.set_bit(Vector2(row, col), false);
		for row in range(w/2+1, w):
			for col in range(h/2+1, h):
				contents.bm.set_bit(Vector2(row, col), false);
	match dir:
		"north":
			for row in range(h/2, h):
				contents.bm.set_bit(Vector2(w/2, row), true);
		"east":
			for col in range(0, w/2):
				contents.bm.set_bit(Vector2(col, h/2), true);
		"south":
			for row in range(0, h/2):
				contents.bm.set_bit(Vector2(w/2, row), true);
		"west":
			for col in range(w/2, w):
				contents.bm.set_bit(Vector2(col, h/2), true);

func generate_key(dir, ex):
	generate_spawn(dir, ex);
	for row in range(0, h/2):
		contents.bm.set_bit(Vector2(w/2, row), true);
	for col in range(w/2, w):
		contents.bm.set_bit(Vector2(col, h/2), true);
	for row in range(h/2, h):
		contents.bm.set_bit(Vector2(w/2, row), true);
	for col in range(0, w/2):
		contents.bm.set_bit(Vector2(col, h/2), true);

func generate_general(dir, ex):
	w = randi() % 5 + 5;
	h = w + (randi() % 3 - 1);
	contents = MGrid.new(w, h);
	if randi() % 3 == 0:
		contents.bm.set_bit(Vector2(0, 0), false);
	if randi() % 3 == 0:
		contents.bm.set_bit(Vector2(w-1, 0), false);
	if randi() % 3 == 0:
		contents.bm.set_bit(Vector2(0, h-1), false);
	if randi() % 3 == 0:
		contents.bm.set_bit(Vector2(w-1, h-1), false);
	for e in ex:
		match e:
			"north":
				exits["north"] = Vector2(w/2, 0);
			"east":
				exits["east"] = Vector2(w-1, h/2);
			"south":
				exits["south"] = Vector2(w/2, h-1);
			"west":
				exits["west"] = Vector2(0, h/2);

func generate_large(dir, ex):
	w = randi() % 10 + 7;
	h = w + (randi() % 7 - 3);
	contents = MGrid.new(w, h);
	if randi() % 2 == 0:
		contents.bm.set_bit(Vector2(0, 0), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(1, 0), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(0, 1), false);
	if randi() % 2 == 0:
		contents.bm.set_bit(Vector2(w-1, 0), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(w-2, 0), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(w-1, 1), false);
	if randi() % 2 == 0:
		contents.bm.set_bit(Vector2(0, h-1), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(1, h-1), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(0, h-2), false);
	if randi() % 2 == 0:
		contents.bm.set_bit(Vector2(w-1, h-1), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(w-2, h-1), false);
		if randi() % 3 == 0:
			contents.bm.set_bit(Vector2(w-1, h-2), false);
	for e in ex:
		match e:
			"north":
				exits["north"] = Vector2(w/2, 0);
			"east":
				exits["east"] = Vector2(w-1, h/2);
			"south":
				exits["south"] = Vector2(w/2, h-1);
			"west":
				exits["west"] = Vector2(0, h/2);
	var center = Vector2((randi() % w-2), (randi() % h-2));
	while !cancircle(center):
		center = Vector2((randi() % w-2), (randi() % h-2));
	circle(center);
	if randi() % 2 == 0:
		center = Vector2((randi() % w-2), (randi() % h-2));
		while !cancircle(center):
			center = Vector2((randi() % w-2), (randi() % h-2));
		circle(center);

func cancircle(center):
	for x in [center.x-1, center.x, center.x+1]:
			for y in [center.y-1, center.y, center.y+1]:
				if Vector2(x, y) in exits.values():
					return false;
	return true;

func generate_library(dir, ex):
	if ex.size() in [1,2]:
		if ex[0] in ["west", "east"]:
			w = randi() % 7 + 15;
			h = 7;
			contents = MGrid.new(w, h);
			contents.bm.set_bit_rect(Rect2(0, 0, w, h), false);
			# Draw Brackets
			contents.bm.set_bit(Vector2(0, 1), true);
			contents.bm.set_bit(Vector2(w-1, 1), true);
			contents.bm.set_bit(Vector2(0, h-2), true);
			contents.bm.set_bit(Vector2(w-1, h-2), true);
			for col in range(w):
				contents.bm.set_bit(Vector2(col, 0), true);
				contents.bm.set_bit(Vector2(col, h-1), true);
			for col in range(1, w-1):
				contents.bm.set_bit(Vector2(col, h/2), true);
			match dir:
				"east":
					for col in range(min(w-4, w-(randi()%12)), w-1):
						contents.bm.set_bit(Vector2(col, 2), true);
						contents.bm.set_bit(Vector2(col, 4), true);
				"west":
					for col in range(1, min(2*w/3, 4+randi()%12)):
						contents.bm.set_bit(Vector2(col, 2), true);
						contents.bm.set_bit(Vector2(col, 4), true);
			if "west" in ex:
				contents.bm.set_bit(Vector2(0, h/2), true);
				exits["west"] = Vector2(0, h/2);
			if "east" in ex:
				contents.bm.set_bit(Vector2(w-1, h/2), true);
				exits["east"] = Vector2(w-1, h/2);
			link_all();
			for col in range(w):
				if contents.bm.get_bit(Vector2(col, 2)):
					var c = contents.get(Vector2(col, 2));
					if c.has_neighbour("East"):
						if randi() % 2 == 0:
							c.unlink(c.neighbours["East"]);
				if contents.bm.get_bit(Vector2(col, 4)):
					var c = contents.get(Vector2(col, 4));
					if c.has_neighbour("East"):
						if randi() % 2 == 0:
							c.unlink(c.neighbours["East"]);
		else:
			w = 7;
			h = randi() % 7 + 15;
			contents = MGrid.new(w, h);
			contents.bm.set_bit_rect(Rect2(0, 0, w, h), false);
			# Draw Brackets
			contents.bm.set_bit(Vector2(1, 0), true);
			contents.bm.set_bit(Vector2(1, h-1), true);
			contents.bm.set_bit(Vector2(w-2, 0), true);
			contents.bm.set_bit(Vector2(w-2, h-1), true);
			for row in range(h):
				contents.bm.set_bit(Vector2(0, row), true);
				contents.bm.set_bit(Vector2(w-1, row), true);
			for row in range(1, h-1):
				contents.bm.set_bit(Vector2(w/2, row), true);
			match dir:
				"north":
					for row in range(1, min(2*h/3, 4+randi()%12)):
						contents.bm.set_bit(Vector2(2, row), true);
						contents.bm.set_bit(Vector2(4, row), true);
				"south":
					for row in range(min(h-4, h-(randi()%12)), h-1):
						contents.bm.set_bit(Vector2(2, row), true);
						contents.bm.set_bit(Vector2(4, row), true);
			if "north" in ex:
				contents.bm.set_bit(Vector2(w/2, 0), true);
				exits["north"] = Vector2(w/2, 0);
			if "south" in ex:
				contents.bm.set_bit(Vector2(w/2, h-1), true);
				exits["south"] = Vector2(w/2, h-1);
			link_all();
			for row in range(h):
				if contents.bm.get_bit(Vector2(2, row)):
					var c = contents.get(Vector2(2, row));
					if c.has_neighbour("North"):
						if randi() % 2 == 0:
							c.unlink(c.neighbours["North"]);
				if contents.bm.get_bit(Vector2(4, row)):
					var c = contents.get(Vector2(4, row));
					if c.has_neighbour("North"):
						if randi() % 2 == 0:
							c.unlink(c.neighbours["North"]);

func generate_deadend(dir, ex):
	if ex.size() == 1:
		if dir in ["north", "south"]:
			w = randi() % 3 + 4;
			h = randi() % 4 + 8;
		else:
			w = randi() % 4 + 8;
			h = randi() % 3 + 4;
		contents = MGrid.new(w, h);
		if randi() % 2 == 0:
			contents.bm.set_bit(Vector2(0, 0), false);
		if randi() % 2 == 0:
			contents.bm.set_bit(Vector2(w-1, 0), false);
		if randi() % 2 == 0:
			contents.bm.set_bit(Vector2(0, h-1), false);
		if randi() % 2 == 0:
			contents.bm.set_bit(Vector2(w-1, h-1), false);
		for e in ex:
			match ex[0]:
				"north":
					exits["north"] = Vector2(w/2, 0);
				"east":
					exits["east"] = Vector2(w-1, h/2);
				"south":
					exits["south"] = Vector2(w/2, h-1);
				"west":
					exits["west"] = Vector2(0, h/2);

func generate_item(dir, ex):
	if ex.size() == 1:
		w = [5, 7, 9][randi() % 3];
		h = w;
		contents = MGrid.new(w, h);
		circle(Vector2(w/2, h/2));
		if w > 5:
			outer_circle(Vector2(w/2, h/2));
			contents.bm.set_bit(Vector2(0, 0), false);
			contents.bm.set_bit(Vector2(w-1, 0), false);
			contents.bm.set_bit(Vector2(0, h-1), false);
			contents.bm.set_bit(Vector2(w-1, h-1), false);
		match dir:
			"north":
				for row in range(0, h/2):
					contents.bm.set_bit(Vector2(w/2, row), true);
			"east":
				for col in range(w/2, w):
					contents.bm.set_bit(Vector2(col, h/2), true);
			"south":
				for row in range(h/2, h):
					contents.bm.set_bit(Vector2(w/2, row), true);
			"west":
				for col in range(0, w/2):
					contents.bm.set_bit(Vector2(col, h/2), true);
		for e in ex:
			match e:
				"north":
					exits["north"] = Vector2(w/2, 0);
				"east":
					exits["east"] = Vector2(w-1, h/2);
				"south":
					exits["south"] = Vector2(w/2, h-1);
				"west":
					exits["west"] = Vector2(0, h/2);

func link_all():
	for c in contents.cells():
		for neighbour in c.nonnull_neighbours():
			c.link(c.neighbours[neighbour]);

func unlink_all():
	for c in contents.cells():
		for neighbour in c.nonnull_neighbours():
			c.unlink(c.neighbours[neighbour]);
