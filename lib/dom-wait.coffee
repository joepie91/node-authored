$ = require "jquery"

domInitialized = false
queue = []

$ ->
	domInitialized = true

	queue.forEach ([thisArg, func, args]) ->
		console.log args
		func.apply(thisArg, args)

	queue = []

domWait = (thisArg, func, args) ->
	if domInitialized
		func.apply(thisArg, args)
	else
		queue.push [thisArg, func, args]

domWait.func = (func) ->
	return ->
		args = []

		# This is needed to avoid killing the optimizer.
		for i in [0...arguments.length]
			args[i] = arguments[i]

		domWait(this, func, args)

module.exports = domWait
