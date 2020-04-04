extends Node

class_name BudgetSystem

var money = 0

func add(value):
	money += value
	GlobalSignal.dispatch("budget_updated", { "value": value, "money": money })

func subtract(value):
	money -= value
	GlobalSignal.dispatch("budget_updated", { "value": value, "money": money })

func multiply(value):
	money *= value
	GlobalSignal.dispatch("budget_updated", { "value": value, "money": money })

func divide(value):
	money /= value
	GlobalSignal.dispatch("budget_updated", { "value": value, "money": money })

func set_money(value):
	money = value
	GlobalSignal.dispatch("budget_set", { "value": value })

func reset():
	money = 0
	GlobalSignal.dispatch("budget_reset")

func can_afford(value):
	return money - value >= 0