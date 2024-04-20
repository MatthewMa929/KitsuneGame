extends Node2D
#11x18
@onready var curr_level = $TileMapA

var cell_size = Vector2i(64, 64)

var astar_grid = AStarGrid2D.new()
var grid_size = Vector2i(18, 11)

func _ready():
	make_grid()

func make_grid():
	grid_size = Vector2i(get_viewport_rect().size) / cell_size
	astar_grid.size = grid_size
	astar_grid.cell_size = cell_size
	astar_grid.offset = cell_size / 2
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.update()
	for x in range(0, grid_size[0]):
		for y in range(0, grid_size[1]):
			var cell_pos = [x, y]
			var cell_posi = Vector2i(cell_pos[0], cell_pos[1])
			if not is_moveable(cell_pos):
				astar_grid.set_point_solid(cell_posi, not astar_grid.is_point_solid(cell_posi))
	#print(astar_grid.get_point_path(Vector2i(15, 8), Vector2i(14, 8)))

func _process(delta):
	pass

func is_moveable(pos):
	var coords = Vector2i(pos[0], pos[1])
	var next_cell = curr_level.get_cell_atlas_coords(0, coords)
	if next_cell == Vector2i(0, 0):
		return false
	return true
