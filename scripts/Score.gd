extends Node

###
# Keeps track of overall game score in a session.
###

var total_score = 0
var current_score = 0

const TOTAL_SCORE_KEY = 'total_score'

const RABBIT_ALIVE_SCORE = 10000
const RABBIT_DEAD_SCORE = -6000
const BUDGET_SCORE = 5
const TIME_SCORE = -(100/60)

const TIME_SCORE_START = 600

func _ready():
	if UserData.has(TOTAL_SCORE_KEY):
		total_score = UserData.get(TOTAL_SCORE_KEY)
	else:
		UserData.set(TOTAL_SCORE_KEY, 0)

func calculate_score(rabbits_alive, rabbits_dead, budget_remaining, time_elapsed):
	if rabbits_alive == 0:
		return 0
	var raw_score = (rabbits_alive * RABBIT_ALIVE_SCORE) + \
		(rabbits_dead * RABBIT_DEAD_SCORE) + \
		(budget_remaining * BUDGET_SCORE) + \
		((time_elapsed * TIME_SCORE) + TIME_SCORE_START)
	return max(raw_score, 0)

func calculate_rabbits_captured_score(rabbits_captured):
	return rabbits_captured * RABBIT_ALIVE_SCORE

func calculate_rabbits_dead_score(rabbits_dead):
	return rabbits_dead * RABBIT_DEAD_SCORE

func calculate_budget_remaining_score(budget_remaining):
	return budget_remaining * BUDGET_SCORE

func calculate_time_elapsed_score(time_elapsed):
	return (time_elapsed * TIME_SCORE) + TIME_SCORE_START

func add_current_score(value):
	current_score += value

func reset_current_score():
	current_score = 0

func add_total_score(value):
	total_score += value
	UserData.set(TOTAL_SCORE_KEY, total_score)

func reset_total_score():
	total_score = 0
	UserData.set(TOTAL_SCORE_KEY, 0)