extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var color = {}
var dict = {}


func _ready() -> void:
	if dict.keys().is_empty():
		init_arr()
		init_color()
		init_dict()
	
	#get_tree().bourse.resource.after_init()
	
func init_arr() -> void:
	arr.value = [1, 2, 3, 4, 5, 6, 7]
	
func init_dict() -> void:
	init_direction()
	init_factorial()
	
	init_dice()
	
func init_direction() -> void:
	dict.direction = {}
	dict.direction.linear2 = [
		Vector2i( 0,-1),
		Vector2i( 1, 0),
		Vector2i( 0, 1),
		Vector2i(-1, 0)
	]
	dict.direction.diagonal = [
		Vector2i( 1,-1),
		Vector2i( 1, 1),
		Vector2i(-1, 1),
		Vector2i(-1,-1)
	]
	
	dict.direction.hybrid = []
	
	for _i in dict.direction.linear2.size():
		var direction = dict.direction.linear2[_i]
		dict.direction.hybrid.append(direction)
		direction = dict.direction.diagonal[_i]
		dict.direction.hybrid.append(direction)
	
func init_factorial() -> void:
	dict.factorial = {}
	var n = 10
	var value = 1
	dict.factorial[0] = 1
	
	for _i in range(1, n, 1):
		value *= _i
		dict.factorial[_i] = int(value)
		
func init_failure() -> void:
	var n = 7
	dict.failure = {}
	dict.old_failure = {}
	
	for aspect in dict.dice.title:
		dict.old_failure[aspect] = {}
		dict.failure[aspect] = {}
		dict.failure[aspect][1] = {}
		
		for value in arr.value:
			dict.failure[aspect][1][[value]] = dict.dice.title[aspect].probabilities[value]
	
	
	for aspect in dict.dice.title:
		for _n in range(2, n, 1):
			dict.failure[aspect][_n] = {}
			var parents = dict.failure[aspect][_n - 1]
			
			for parent in parents:
				for _i in range(parent.back() + 1, n + 1, 1):
					var child = parent.duplicate()
					child.append(_i)
					dict.failure[aspect][_n][child] = float(dict.failure[aspect][_n - 1][parent]) + dict.dice.title[aspect].probabilities[_i]
		
		dict.failure[aspect][n] = {}
		dict.failure[aspect][n][arr.value] = 1.0
		
	#for aspect in dict.failure:
		#for _n in dict.failure[aspect]:
			#dict.old_failure[aspect][_n] = {}
			#
			#for valus in dict.failure[aspect][_n]:
				#dict.old_failure[aspect][_n][valus] = 1.0 - dict.failure[aspect][_n][valus]
	
func init_dice() -> void:
	dict.dice = {}
	dict.dice.title = {}
	
	var path = "res://entities/dice/dice.json"
	var array = load_data(path)
	
	for dice in array:
		var data = {}
		var words = dice.values.split(",")
		data.values = []
		data.probabilities = {}
		
		for word in words:
			var value = int(word)
			data.values.append(value)
			
			if !data.probabilities.has(value):
				data.probabilities[value] = 0
			
			data.probabilities[value] += 1.0 / words.size()
		
		for value in arr.value:
			if !data.probabilities.has(value):
				data.probabilities[value] = 0.0
		
		var title = Constants.ASPECT.get(dice.title.to_upper())
		dict.dice.title[title] = data
	
	init_failure()
	
func init_color():
	pass
	#var h = 360.0
	
func save(path_: String, data_): #: String
	var file = FileAccess.open(path_, FileAccess.WRITE)
	file.store_string(data_)
	
func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var _parse_err = json_object.parse(text)
	return json_object.get_data()
	
func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	if true:
		var keys = dict_.keys()
		var weights = PackedFloat32Array()
		
		for key in keys:
			weights.append(float(dict_[key]))
		
		return keys[rng.rand_weighted(weights)]
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null
	
func get_all_combinations(origin_: Dictionary) -> Dictionary:
	var combinations = {}
	combinations[0] = [origin_]
	combinations[1] = []
	var limit = 0
	
	for value in origin_:
		var child = {}
		child[value] = 1
		combinations[1].append(child)
		limit += origin_[value]
	
	for _i in limit - 1:
		set_combinations_based_on_size(combinations, _i + 2)
	
	return combinations
	
func get_all_combinations_based_on_size(origin_: Dictionary, size_: int) -> Array:
	var combinations = {}
	combinations[0] = [origin_]
	combinations[1] = []
	
	for value in origin_:
		var child = {}
		child[value] = 1
		combinations[1].append(child)
	
	for _i in size_:
		set_combinations_based_on_size(combinations, _i + 2)
	
	return combinations[size_]
	
func set_combinations_based_on_size(combinations_: Dictionary, size_: int) -> void:
	var parents = combinations_[size_ - 1]
	combinations_[size_] = []
	
	for parent in parents:
		var childs = get_unused_values(parent, combinations_[0].front())
		
		for child in childs:
			var combination = parent.duplicate()
			
			if !combination.has(child):
				combination[child] = 0
			
			combination[child] += 1
			
			if !combinations_[size_].has(combination):
				combinations_[size_].append(combination)
	
func get_unused_values(parent_: Dictionary, origin_: Dictionary) -> Array:
	var unuseds = []
	
	for value in origin_:
		var count = origin_[value]
		
		if parent_.has(value):
			count -= parent_[value]
		
		if count > 0:
			unuseds.append(value)
	
	return unuseds
	
func calc_probability(aspect_: Constants.ASPECT, value_: int, n_: int, k_: int) -> float:
	var probability = dict.dice.title[aspect_].probabilities[value_]
	return pow(probability, n_) * pow(1 - probability, k_ - n_)
	
func get_pascal_triangle(n_: int, k_: int) -> int:
	if k_ >= n_:
		return 1
	
	if k_ <= 0:
		return 1
	
	var result = dict.factorial[n_]
	result /= dict.factorial[k_]
	
	if n_ - k_ > 0:
		result /= dict.factorial[n_ - k_]
	
	#var result = 1
	#for _i in range(k_ + 1, n_ + 1, 1):
		#result *= _i
	#
	#for _i in range(2, n_ - k_ + 1, 1):
		#result /= _i
	
	return result
	
func get_partial_permutation(n_: int, k_: int) -> int:
	var result = dict.factorial[n_]
	result /= dict.factorial[n_ - k_]
	#print([result, n_, k_, dict.factorial[n_], dict.factorial[n_ - k]])
	return result
	
func get_negative_combination(origin_combination_: Dictionary, positive_combination_: Dictionary) -> Dictionary:
	var negative_combination = origin_combination_.duplicate()
	
	for value in positive_combination_:
		negative_combination[value] -= positive_combination_[value]
		
		if negative_combination[value] <= 0:
			negative_combination.erase(value)
	
	return negative_combination
	
func get_full_combination(origin_combination_: Dictionary, positive_combination_: Dictionary) -> Dictionary:
	var full_combination_ = positive_combination_.duplicate()
	
	for value in origin_combination_:
		if !full_combination_.has(value):
			full_combination_[value] = 0
	
	return full_combination_
	
func rnd_log_normal(a_: float, b_: float) -> float:
	var value = smoothstep(-4, 4, randfn(0, 1))
	return a_ + value * (b_ + 1 - a_)
	
func rnd_log_normal_int(a_: float, b_: float) -> int:
	return int(rnd_log_normal(a_, b_))
	
func rnd_basic_levy() -> float:
	#var n = randfn(0, 1.0)
	#var mean = 0
	#var deviation = 2
	#return mean + deviation / pow(n, 2)
	return 2 / pow(randfn(0, 1), 2) / 10
	
func rnd_levy(a_: float, b_: float) -> float:
	var value = rnd_basic_levy()
	
	while value >= 1:
		value = rnd_basic_levy()
	
	return a_ + value * (b_ + 1 - a_)
	
func rnd_levy_int(a_: float, b_: float) -> int:
	return  int(rnd_levy(a_, b_))
	
func roll_dice(aspect_: Constants.ASPECT) -> int:
	return dict.dice.title[aspect_].values.pick_random()
	
func roll_dices(aspect_: Constants.ASPECT, n_: int) -> Dictionary:
	var rolls = {}
	
	for _i in n_:
		var value = roll_dice(aspect_)
		
		if !rolls.has(value):
			rolls[value] = 0
		
		rolls[value] += 1
	
	return rolls
	
func calc_failure_probability(aspects_: Dictionary, bans_: Array) -> float:
	#var n = Global.dict.dice.title[Global.dict.dice.title.keys().front()].size()
	
	var failure_probability = 1.0
	
	#for aspect in aspects_:
		#var failure = pow(dict.old_failure[aspect][bans_.size()][bans_], aspects_[aspect])
		#failure_probability *= failure
	
	
	#var success_probabilities = []
	#
	for aspect in aspects_:
		var failure = pow(dict.failure[aspect][bans_.size()][bans_], aspects_[aspect])
		failure_probability *= failure
		#success_probabilities.append(success)
	#
	#success_probabilities.sort()
	#var failure_probability = 1.0 - success_probabilities.back()
	
	#print(failure_probability)
	return failure_probability
