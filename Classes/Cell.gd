class_name Cell

var col;
var row;
var neighbours = {};
var links = {};
var type;
var contents;

enum CellType {
	Start,
	End,
	Plain,
	Item,
	Key,
	Star
}

func _init(c, r, t):
	col = c;
	row = r;
	type = t;

func link(other, bidi=true):
	links[other] = true;
	if bidi:
		other.link(self, false);

func unlink(other, bidi=true):
	links.erase(other);
	if bidi:
		other.unlink(self, false);

func link_list():
	return links.keys();

func linked_to(other):
	return other in link_list();

func nonnull_neighbours():
	var n = {};
	for dir in neighbours.keys():
		if has_neighbour(dir):
			n[dir] = neighbours[dir];
		pass
	return n;

func neighbour_list():
	return nonnull_neighbours().values();

func link_unlinked_neighbour():
	var neighbours = neighbour_list();
	neighbours.shuffle();
	for n in neighbours:
		if !linked_to(n):
			link(n);
			return;

func has_neighbour(dir):
	return neighbours[dir] != null;

func mark(t, c=null):
	type = t;
	contents = c;

func distances():
	var d = Distances.new(self);
	var frontier = [self];
	while frontier.size() > 0:
		var n_frontier = [];
		for c in frontier:
			for link in c.link_list():
				if not (link in d.cell_list()) and link.nonnull_neighbours().size() != 0:
					d.set(link, d.get(c)+1);
					n_frontier.append(link);
		frontier = n_frontier;
	return d;

func available_neighbours():
	var result = [];
	for neighbour in nonnull_neighbours().values():
		if neighbour.links.size() == 0:
			result.append(neighbour);
	return result;
