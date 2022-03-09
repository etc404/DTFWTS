class_name KruskalsState

var neighbours = [];
var set_for_cell = {};
var cells_in_set = {};

func _init(input):
	for c in input.cells():
		var set = set_for_cell.size();
		set_for_cell[c] = set;
		cells_in_set[set] = [c];
		if c.nonnull_neighbours().size() > 0:
			if c.has_neighbour("South"):
				neighbours.append([c, c.neighbours["South"]]);
			if c.has_neighbour("East"):
				neighbours.append([c, c.neighbours["East"]]);
func can_merge(left, right):
	return set_for_cell[left] != set_for_cell[right];

func merge(left, right):
	left.link(right);
	var winner = set_for_cell[left];
	var loser = set_for_cell[right];
	var losers = cells_in_set[loser];
	for c in losers:
		cells_in_set[winner].append(c);
		set_for_cell[c] = winner;
	cells_in_set.erase(loser);
