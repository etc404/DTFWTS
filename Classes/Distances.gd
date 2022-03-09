class_name Distances

var root;
var cells = {};

func _init(r):
	root = r;
	cells[root] = 0;

func get(c):
	return cells[c];

func set(c, dist):
	cells[c] = dist;

func cell_list():
	return cells.keys();

func farthest():
	var maxim = 0
	var maxcell = root;
	for key in cells.keys():
		if cells[key] > maxim:
			maxim = cells[key];
			maxcell = key;
	return maxcell;

func max_distance():
	return get(farthest());

func parent(c):
	for key in c.links:
		if cells[key] == cells[c]-1:
			return key;
	return c;
