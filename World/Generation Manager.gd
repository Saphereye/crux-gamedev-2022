# Conditional export variable : https://github.com/godotengine/godot-proposals/issues/2582#issuecomment-817194312
tool
extends Node2D

export(String) var terrain
export(bool) var is_allowed_horizontal = true
export(bool) var is_present_fauna = true

export(bool) var is_geographical_variation = true setget set_geo_variation
var variation_ratio: float setget set_variation_frequency

func set_geo_variation(p_pickable) -> void:
	is_geographical_variation = p_pickable
	property_list_changed_notify()

func set_variation_frequency(value) -> void:
	variation_ratio = clamp(value, 0, 1)

func _get_property_list() -> Array:
	var list = []
	if is_geographical_variation:
		list.push_back(
			{ name = "variation_ratio", type =  TYPE_REAL}
		)
	return list

var rng = RandomNumberGenerator.new()

var current_pos: Vector2 = Vector2.ZERO

var templates: Dictionary = {
	# 0 list gives position of all tiles
	# 1 list gives position of all possible terrain variations
	# 2 list give looking up spikes
	# 3 list give looking down spikes
	# 4 list gove goblin spawn
	# 5 list gives flora fauna spawn locations
	# 6 element is widht
	# 7 is height
	# (L)eft (R)ight (T)op (D)own
	# 0 to 6 are normal
	# 7 to 8 are opposites of the normal templates 
	
	#LR
	"0" : [
		[
			[0, 0],[0, 1],[0, 10],[0, 11],[0, 12],[0, 13],[0, 14],[0, 15],[1, 0],[1, 1],[1, 10],[1, 11],[1, 12],[1, 13],[1, 14],[1, 15],[2, 0],[2, 1],[2, 2],[2, 10],[2, 11],[2, 13],[2, 14],[2, 15],[3, 0],[3, 1],[3, 2],[3, 10],[3, 11],[3, 13],[3, 14],[3, 15],[4, 0],[4, 1],[4, 2],[4, 10],[4, 11],[4, 12],[4, 13],[4, 14],[4, 15],[5, 0],[5, 1],[5, 2],[5, 10],[5, 11],[5, 12],[5, 13],[5, 14],[5, 15],[6, 0],[6, 1],[6, 10],[6, 11],[6, 12],[6, 13],[6, 14],[6, 15],[7, 0],[7, 1],[7, 10],[7, 11],[7, 12],[7, 14],[7, 15],[8, 0],[8, 1],[8, 10],[8, 11],[8, 12],[8, 14],[8, 15],[9, 0],[9, 1],[9, 10],[9, 11],[9, 12],[9, 13],[9, 14],[9, 15],[10, 0],[10, 1],[10, 10],[10, 11],[10, 12],[10, 13],[10, 14],[10, 15],[11, 0],[11, 1],[11, 10],[11, 11],[11, 12],[11, 13],[11, 14],[11, 15],[12, 0],[12, 1],[12, 2],[12, 3],[12, 10],[12, 11],[12, 13],[12, 14],[12, 15],[13, 0],[13, 1],[13, 2],[13, 3],[13, 10],[13, 11],[13, 13],[13, 14],[13, 15],[14, 0],[14, 1],[14, 2],[14, 10],[14, 11],[14, 12],[14, 13],[14, 14],[14, 15],[15, 0],[15, 1],[15, 2],[15, 10],[15, 11],[15, 12],[15, 13],[15, 14],[15, 15],
		],
		[
			[0, 2],[0, 9],[2, 3],[2, 9],[2, 12],[4, 3],[4, 9],[6, 2],[6, 9],[7, 13],[8, 2],[8, 9],[10, 2],[10, 9],[12, 4],[12, 9],[12, 12],[14, 3],
		],
		16,
		16
	],
	
	#LD
	"1" : [
		[
			 [0, 0],[0, 1],[0, 10],[0, 11],[0, 12],[0, 13],[0, 14],[0, 15],[1, 0],[1, 1],[1, 10],[1, 11],[1, 12],[1, 13],[1, 14],[1, 15],[2, 0],[2, 1],[2, 10],[2, 11],[2, 14],[2, 15],[3, 0],[3, 1],[3, 10],[3, 11],[3, 14],[3, 15],[4, 0],[4, 1],[5, 0],[5, 1],[6, 0],[6, 1],[7, 0],[7, 1],[8, 0],[8, 1],[9, 0],[9, 1],[10, 0],[10, 1],[11, 0],[11, 1],[12, 0],[12, 1],[12, 2],[12, 3],[12, 6],[12, 7],[12, 10],[12, 11],[12, 14],[12, 15],[13, 0],[13, 1],[13, 2],[13, 3],[13, 6],[13, 7],[13, 10],[13, 11],[13, 14],[13, 15],[14, 0],[14, 1],[14, 2],[14, 3],[14, 4],[14, 5],[14, 6],[14, 7],[14, 8],[14, 9],[14, 10],[14, 11],[14, 12],[14, 13],[14, 14],[14, 15],[15, 0],[15, 1],[15, 2],[15, 3],[15, 4],[15, 5],[15, 6],[15, 7],[15, 8],[15, 9],[15, 10],[15, 11],[15, 12],[15, 13],[15, 14],[15, 15],
		],
		[
			[0, 2],[0, 9],[2, 2],[2, 9],[2, 12],[2, 13],[4, 2],[6, 2],[8, 2],[10, 2],[12, 4],[12, 5],[12, 8],[12, 9],[12, 12],[12, 13],
		],
		16,
		16
	],
	
	#TD
	"2" : [
		[
			[0, 0],[0, 1],[0, 2],[0, 3],[0, 4],[0, 5],[0, 6],[0, 7],[0, 8],[0, 9],[0, 10],[0, 11],[0, 12],[0, 13],[0, 14],[0, 15],[1, 0],[1, 1],[1, 2],[1, 3],[1, 4],[1, 5],[1, 6],[1, 7],[1, 8],[1, 9],[1, 10],[1, 11],[1, 12],[1, 13],[1, 14],[1, 15],[2, 0],[2, 1],[2, 2],[2, 3],[2, 4],[2, 5],[2, 6],[2, 9],[2, 10],[2, 11],[2, 12],[2, 13],[2, 14],[2, 15],[3, 0],[3, 1],[3, 2],[3, 3],[3, 4],[3, 5],[3, 6],[3, 9],[3, 10],[3, 11],[3, 12],[3, 13],[3, 14],[3, 15],[4, 3],[4, 4],[4, 13],[4, 14],[5, 3],[5, 4],[5, 13],[5, 14],[6, 3],[6, 4],[6, 13],[6, 14],[7, 3],[7, 4],[7, 13],[7, 14],[8, 8],[8, 9],[9, 8],[9, 9],[10, 8],[10, 9],[11, 8],[11, 9],[12, 1],[12, 2],[12, 5],[12, 6],[12, 7],[12, 8],[12, 9],[12, 10],[12, 11],[12, 12],[12, 13],[12, 14],[12, 15],[13, 1],[13, 2],[13, 5],[13, 6],[13, 7],[13, 8],[13, 9],[13, 10],[13, 11],[13, 12],[13, 13],[13, 14],[13, 15],[14, 0],[14, 1],[14, 2],[14, 3],[14, 4],[14, 5],[14, 6],[14, 7],[14, 8],[14, 9],[14, 10],[14, 11],[14, 12],[14, 13],[14, 14],[14, 15],[15, 0],[15, 1],[15, 2],[15, 3],[15, 4],[15, 5],[15, 6],[15, 7],[15, 8],[15, 9],[15, 10],[15, 11],[15, 12],[15, 13],[15, 14],[15, 15],
		],
		[
			[2, 7],[2, 8],[4, 2],[4, 5],[4, 12],[4, 15],[6, 2],[6, 12],[8, 7],[10, 7],[10, 10],[12, 0],[12, 3],[12, 4],
		],
		16,
		16
	]
}

#var template_list = ["─", "┐", "│", "┌", "┘", "└"]

#var adjacency: Dictionary = {
#	"─" : ["─", "┐"],
#	"┐" : ["│"],
#	"│" : ["│"]
#}

#var previous_template = "─"
#var current_template = "─"

func _ready() -> void:
	create_world()
		
func list_rand_element(list) -> String:
	return list[randi() % list.size()]

func create_world() -> void:
	$TileMap.clear()
	for current_template in terrain:
		rng.randomize()
#		print(current_template)
		for coor in templates[current_template][0]:
			$TileMap.set_cell(current_pos.x + coor[0], current_pos.y + coor[1], 0)
		for coor in templates[current_template][1]:
			if rng.randf() > variation_ratio:
				$TileMap.set_cell(current_pos.x + coor[0], current_pos.y + coor[1], 0)
				$TileMap.set_cell(current_pos.x + 1 + coor[0], current_pos.y + coor[1], 0)
		$TileMap.update_bitmask_region(current_pos, current_pos + Vector2(templates[current_template][2], templates[current_template][3]))
		match current_template:
			"0":
				current_pos += Vector2(templates[current_template][2], 0)
			"1":
				current_pos += Vector2(0, templates[current_template][3])
			"2":
				current_pos += Vector2(0, templates[current_template][3])
#		current_template = list_rand_element(adjacency[previous_template])
#		previous_template = current_template


func _on_Dice_difficulty_changed() -> void:
	print("new world")
	current_pos = Vector2.ZERO
	create_world()
