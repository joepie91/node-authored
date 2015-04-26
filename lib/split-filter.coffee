module.exports = (array, filterFunc) ->
	matches = []
	nonMatches = []

	array.forEach (item, i) ->
		if filterFunc(item, i)
			matches.push item
		else
			nonMatches.push item

	return [matches, nonMatches]
