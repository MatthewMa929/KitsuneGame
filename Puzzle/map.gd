extends Node2D
#11x18
@onready var levelA = $TileMapA
@onready var levelB = $TileMapB
@onready var levelC = $TileMapC
@onready var levelCT = $TileMapCT
@onready var puzzle = $".."
@onready var enemy = $Enemy
@onready var curr_level = levelC
@onready var status = curr_level.status
@onready var ori_status = status.duplicate(true)
@onready var lit_torch_spr = $LitTorch
@onready var unlit_torch_spr = $UnlitTorch
@onready var stages = [levelCT, levelC, levelA, levelB]

var cell_size = Vector2i(64, 64)

var astar_grid = AStarGrid2D.new()
var grid_size = Vector2i(18, 11)
var torch_pos = []
var torches = []
var old_lit = []
var walls = [Vector2i(2, 1), Vector2i(2, 0), Vector2i(0, 0), Vector2i(0, 1)]
var torch_cells = [Vector2i(2, 1), Vector2i(2, 0)]
var lit_torch_sprs = []
var unlit_torch_sprs = []
var curr_stg = false
var puzzle_num = 0

signal set_up_spawns

func _ready():
	pass

func make_grid():
	astar_grid.clear()
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
			var cell_posi = Vector2i(x, y)
			if is_wall(cell_pos):
				astar_grid.set_point_solid(cell_posi, true)
			if is_torch(cell_pos):
				torches.append(direc_array(cell_pos))
				var lit_torch = lit_torch_spr.duplicate(true)
				var unlit_torch = unlit_torch_spr.duplicate(true)
				add_child(lit_torch)
				add_child(unlit_torch)
				lit_torch.position = Vector2(cell_pos[0]*64, cell_pos[1]*64)
				lit_torch_sprs.append(lit_torch)
				unlit_torch.position = Vector2(cell_pos[0]*64, cell_pos[1]*64)
				unlit_torch_sprs.append(unlit_torch)
				print(lit_torch_sprs)
	for t in range(0, torches.size()):
		torch_pos.append(torches[t][0])
	#torch_pos = [torches[0][0], torches[1][0], torches[2][0]]
	#astar_grid.update()
func make_grid_dark():
	for x in range(0, grid_size[0]):
		for y in range(0, grid_size[1]):
			var cell_pos = [x, y]
			var cell_posi = Vector2i(x, y)
			var cell = curr_level.get_cell_atlas_coords(0, cell_posi)
			if cell == Vector2i(1, 0):
				curr_level.set_cell(0, cell_posi, 0, Vector2i(1, 1))
			if cell == Vector2i(2, 0):
				curr_level.set_cell(0, cell_posi, 0, Vector2i(2, 1))

func make_grid_light():
	for x in range(0, grid_size[0]):
		for y in range(0, grid_size[1]):
			var cell_pos = [x, y]
			var cell_posi = Vector2i(x, y)
			var cell = curr_level.get_cell_atlas_coords(0, cell_posi)
			if cell == Vector2i(1, 1):
				curr_level.set_cell(0, cell_posi, 0, Vector2i(1, 0))
			if cell == Vector2i(2, 1):
				curr_level.set_cell(0, cell_posi, 0, Vector2i(2, 0))

func _process(delta):
	for i in range(torches.size()):
		if status[i]: #Torch on
			unlit_torch_sprs[i].visible = false
			lit_torch_sprs[i].visible = true
		else:         #Torch off
			unlit_torch_sprs[i].visible = true
			lit_torch_sprs[i].visible = false

func _unhandled_input(event):
	pass
	#if Input.is_action_just_pressed("Next"):
		#curr_stg = !curr_stg
	#if curr_stg:
		#curr_level = levelA
	#else:
		#curr_level = levelB

func is_wall(pos):
	var coords = Vector2i(pos[0], pos[1])
	var cell = curr_level.get_cell_atlas_coords(0, coords)
	if cell in walls:
		return true
	return false

func is_torch(pos):
	var coords = Vector2i(pos[0], pos[1])
	var cell = curr_level.get_cell_atlas_coords(0, coords)
	if cell in torch_cells:
		return true
	return false

func direc_array(cell_pos):
	var cell_up = [cell_pos[0], cell_pos[1] - 1]
	var cell_down = [cell_pos[0], cell_pos[1] + 1]
	var cell_left = [cell_pos[0] - 1, cell_pos[1]]
	var cell_right = [cell_pos[0] + 1, cell_pos[1]]
	var cell_posi = Vector2i(cell_pos[0], cell_pos[1])
	var empty_spaces = [cell_posi]
	if not is_wall(cell_up):
		empty_spaces.append(Vector2i(cell_up[0], cell_up[1]))
	if not is_wall(cell_down):
		empty_spaces.append(Vector2i(cell_down[0], cell_down[1]))
	if not is_wall(cell_left):
		empty_spaces.append(Vector2i(cell_left[0], cell_left[1]))
	if not is_wall(cell_right):
		empty_spaces.append(Vector2i(cell_right[0], cell_right[1]))
	return empty_spaces

func _on_puzzle_lantern_moved(lantern_light):
	for i in range(1, old_lit.size()):
		astar_grid.set_point_solid(old_lit[i], false)
		curr_level.set_cell(0, old_lit[i], 0, Vector2i(1, 0))
	for i in range(1, lantern_light.size()):
		astar_grid.set_point_solid(lantern_light[i], true)
	for i in range(0, lantern_light.size()):
		curr_level.set_cell(0, lantern_light[i], 0, Vector2i(3, 0))
	old_lit = lantern_light

func new_puzzle():
	enemy.reset()
	puzzle.lantern_light = []
	torch_pos = []
	_on_puzzle_lantern_moved(puzzle.lantern_light)
	for stage in stages:
		stage.visible = false
	for i in range(lit_torch_sprs.size()):
		lit_torch_sprs[i].queue_free()
		unlit_torch_sprs[i].queue_free()
	curr_level = stages[puzzle_num]
	puzzle.tileMap = curr_level
	enemy.global_position = curr_level.enemy_spawn
	curr_level.visible = true
	status = curr_level.status
	ori_status = status.duplicate(true)
	puzzle.collidable = []
	torches = []
	lit_torch_sprs = []
	unlit_torch_sprs = []
	make_grid()
	puzzle_num += 1
	emit_signal("set_up_spawns")
	
