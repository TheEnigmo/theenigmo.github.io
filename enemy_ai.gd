class_name EnemyAI
extends RefCounted
## Handles enemy unit decision making.

var grid: Grid

func setup(grid_ref: Grid) -> void:
	grid = grid_ref

func decide_action(enemy: Unit) -> Dictionary:
	var result := {
		"action": "wait",
		"move_to": enemy.data.coordinate,
		"target": null
	}
	
	var player_units := _get_alive_player_units()
	if player_units.is_empty():
		return result
	
	var movement_range := enemy.data.get_movement_range()
	var reachable_tiles := grid.get_tiles_in_movement_range(enemy.data.coordinate, movement_range, enemy.data.unit_type)
	reachable_tiles.append(enemy.data.coordinate)
	
	var best_score: float = -999999.0
	var best_target: Unit = null
	var best_position: Vector2i = enemy.data.coordinate
	
	for player in player_units:
		var evaluation := _evaluate_target(enemy, player, reachable_tiles)
		
		if evaluation["can_attack"] and evaluation["score"] > best_score:
			best_score = evaluation["score"]
			best_target = player
			best_position = evaluation["attack_from"]
	
	if best_target != null:
		result["action"] = "attack"
		result["move_to"] = best_position
		result["target"] = best_target
	else:
		var closest_player := _find_closest_player(enemy, player_units)
		if closest_player != null:
			var move_toward := _get_move_toward_target(enemy, closest_player)
			result["move_to"] = move_toward
	
	return result

func _get_alive_player_units() -> Array[Unit]:
	var alive: Array[Unit] = []
	for unit in grid.units:
		if unit.data.unit_type == Enums.UnitType.PLAYER and unit.data.is_alive():
			alive.append(unit)
	return alive

func _evaluate_target(enemy: Unit, target: Unit, reachable_tiles: Array[Vector2i]) -> Dictionary:
	var result := {
		"can_attack": false,
		"score": -999999.0,
		"attack_from": enemy.data.coordinate
	}
	
	var valid_attack_positions: Array[Vector2i] = []
	
	for tile_coord in reachable_tiles:
		if not grid.is_tile_empty(tile_coord) and tile_coord != enemy.data.coordinate:
			continue
		
		var distance := grid.get_manhattan_distance(tile_coord, target.data.coordinate)
		if _is_in_attack_range(enemy.data.get_attack_range(), distance):
			valid_attack_positions.append(tile_coord)
	
	if valid_attack_positions.is_empty():
		return result
	
	result["can_attack"] = true
	
	var best_attack_pos: Vector2i = valid_attack_positions[0]
	var shortest_move: int = grid.get_manhattan_distance(enemy.data.coordinate, valid_attack_positions[0])
	
	for pos in valid_attack_positions:
		var move_dist := grid.get_manhattan_distance(enemy.data.coordinate, pos)
		if move_dist < shortest_move:
			shortest_move = move_dist
			best_attack_pos = pos
	
	result["attack_from"] = best_attack_pos
	
	var distance_to_target := grid.get_manhattan_distance(best_attack_pos, target.data.coordinate)
	result["score"] = _calculate_target_priority(enemy, target, distance_to_target)
	
	return result

func _is_in_attack_range(attack_range: Enums.AttackRange, distance: int) -> bool:
	match attack_range:
		Enums.AttackRange.RANGE_0:
			return false
		Enums.AttackRange.RANGE_1:
			return distance == 1
		Enums.AttackRange.RANGE_2:
			return distance == 2
		Enums.AttackRange.RANGE_1_2:
			return distance == 1 or distance == 2
	return false

func _calculate_target_priority(enemy: Unit, target: Unit, distance: int) -> float:
	var score: float = 0.0
	
	var can_counter := CombatCalculator.can_counterattack(target.data, enemy.data, distance)
	if not can_counter:
		score += 1000.0
	
	var hp_percent: float = float(target.data.hp_current) / float(target.data.hp_max)
	score += (1.0 - hp_percent) * 100.0
	
	var class_modifier := CombatCalculator.get_class_matchup_modifier(enemy.data.class_id, target.data.class_id)
	if class_modifier > 0:
		score += 50.0
	elif class_modifier < 0:
		score -= 25.0
	
	score += 10.0 - float(distance)
	
	return score

func _find_closest_player(enemy: Unit, player_units: Array[Unit]) -> Unit:
	var closest: Unit = null
	var closest_dist: int = 999999
	
	for player in player_units:
		var dist := grid.get_manhattan_distance(enemy.data.coordinate, player.data.coordinate)
		if dist < closest_dist:
			closest_dist = dist
			closest = player
	
	return closest

func _get_move_toward_target(enemy: Unit, target: Unit) -> Vector2i:
	var movement_range := enemy.data.get_movement_range()
	var reachable := grid.get_tiles_in_movement_range(enemy.data.coordinate, movement_range, enemy.data.unit_type)
	
	if reachable.is_empty():
		return enemy.data.coordinate
	
	var best_tile: Vector2i = enemy.data.coordinate
	var best_distance: int = grid.get_manhattan_distance(enemy.data.coordinate, target.data.coordinate)
	
	for coord in reachable:
		if not grid.is_tile_empty(coord):
			continue
		var dist := grid.get_manhattan_distance(coord, target.data.coordinate)
		if dist < best_distance:
			best_distance = dist
			best_tile = coord
	 
	return best_tile
