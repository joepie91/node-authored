module.exports = (map, object, domElement) ->
	Object.keys(map).forEach (key) ->
		if typeof map[key] == "function"
			valueFunc = map[key]

			object.on "changed:#{key}", (val) ->
				[targetName, actualValue] = valueFunc(val)
				domElement.css targetName, actualValue
		else
			object.on "changed:#{key}", (val) ->
				domElement.css map[key], val
