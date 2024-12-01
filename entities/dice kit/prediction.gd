class_name Prediction extends Resource


var total_aspects: Dictionary
var unrolled_aspects: Dictionary
var dropped_values: Dictionary
var total_aspect_counter: int = 0
var used_sum: int = 0
var roll_outcomes: Dictionary
var risk_limiter: float = 0.6


func change_total_aspect(aspect_: Constants.ASPECT, value_: int) -> void:
	if !total_aspects.has(aspect_):
		total_aspects[aspect_] = 0
	
	total_aspects[aspect_] += value_
	
	if total_aspects[aspect_] <= 0:
		total_aspects.erase(aspect_)
	
	total_aspect_counter += value_
	
func change_unrolled_aspects(aspect_: Constants.ASPECT, value_: int) -> void:
	if !unrolled_aspects.has(aspect_):
		unrolled_aspects[aspect_] = 0
	
	unrolled_aspects[aspect_] += value_
	
	if unrolled_aspects[aspect_] <= 0:
		unrolled_aspects.erase(aspect_)
	
	total_aspect_counter += value_
	
func change_dropped_values(aspect_: Constants.ASPECT, value_: int) -> void:
	if !dropped_values.has(value_):
		dropped_values[value_] = []
	
	dropped_values[value_].append(aspect_)
	change_unrolled_aspects(aspect_, -1)
	
func reset() -> void:
	unrolled_aspects = total_aspects.duplicate()
	dropped_values = {}
	roll_outcomes = {}
	used_sum = 0
	
func calc_repetitions_probability() -> Dictionary:
	var combinations = Global.get_all_combinations(unrolled_aspects)
	var probabilities = {}
	
	for _i in range(2, total_aspect_counter + 1):
		probabilities[_i] = {}
		
		for value in Global.arr.value:
			probabilities[_i][value] = 0
			
			for positive_combination in combinations[_i]:
				var probability = 1.0
				var permutations = 1
				var full_combination = Global.get_full_combination(unrolled_aspects, positive_combination)
				
				for aspect in full_combination:
					if unrolled_aspects[aspect] > 1 and (full_combination[aspect] != unrolled_aspects[aspect] and full_combination[aspect] != 0):
						permutations *= Global.get_pascal_triangle(unrolled_aspects[aspect], full_combination[aspect])
					
					var repetitions_probability = Global.calc_probability(aspect, value, full_combination[aspect], unrolled_aspects[aspect])
					probability *= repetitions_probability
				
				probabilities[_i][value] += probability * permutations
	
	return probabilities
	
func get_rnd() -> void:
	if true:
		var a = {}
		a[1] = 1
		a[2] = 2
		a[3] = 3
		a[4] = 4
		var result = {}
		
		for _i in 10:
			#var value = Global.get_random_key(a)
			#var value = int(randfn(0.0, sqrt(2.0)))
			#var value = int(Global.rnd_levy(1, 2))
			#var value = int(randf_range(1, 5+1))
			
			
			#if value < -10:
				#value = -10
			#
			#if value > 10:
				#value = 10
			
			var value = Global.rnd_levy_int(1, 15)
			
			if !result.has(value):
				result[value] = 0
			
			result[value] += 1
		
		var keys = result.keys()
		keys.sort()
		
		for key in keys:
			print([key, result[key]])
		return
	
func sim_rolls() -> void:
	var repeats = 500000
	var result = {}
	result[1] = {}
	
	for _i in repeats:
		var sum_roll = {}
		
		for aspect in unrolled_aspects:
			var aspect_roll = Global.roll_dices(aspect, unrolled_aspects[aspect])
		
			for value in aspect_roll:
				if !sum_roll.has(value):
					sum_roll[value] = 0
				
				sum_roll[value] += aspect_roll[value]
		
		#single
		var flag = true
		var _max_value = 0
		
		for value in sum_roll:
			if sum_roll[value] != 1:
				flag = false
				break
			else:
				if _max_value < value:
					_max_value = value
		
		if flag:
			if !result[1].has(_max_value):
				result[1][_max_value] = 0
			
			result[1][_max_value] += 1
		
		#repeats
		#for value in sum_roll:
			#var count = sum_roll[value]
			#
			#if  count > 1:
				#if !result.has(count):
					#result[count] = {}
				#
				#if !result[count].has(value):
					#result[count][value] = 0
					#
				#result[count][value] += 1
	
	var counts = result.keys()
	counts.sort()
	
	for count in counts:
		var values = result[count].keys()
		values.sort_custom(func(a, b): return a > b)
		
		for value in values:
			print([count, value, float(result[count][value]) / repeats * 100])
	
func roll_dices() -> void:
	roll_outcomes = {}
	
	for aspect in unrolled_aspects:
		var aspect_roll = Global.roll_dices(aspect, unrolled_aspects[aspect])
	
		for value in aspect_roll:
			if !roll_outcomes.has(value):
				roll_outcomes[value] = []
			
			roll_outcomes[value].append(aspect)
	
	print(roll_outcomes)
	
	for value in roll_outcomes:
		consider_option(value)
	
func consider_option(option_: int) -> void:
	var consequence = unrolled_aspects.duplicate()
	
	for aspect in roll_outcomes[option_]:
		consequence[aspect] -= 1
		
		if consequence[aspect] == 0:
			consequence.erase(aspect)
	
	var bans = dropped_values.keys()
	bans.append(option_)
	bans.sort()
	
	var failure_probability = Global.calc_failure_probability(consequence, bans)
	print([option_, consequence,  bans, failure_probability * 100])
