attributes =
	source:
		type: "string"

API = (stage) ->
	stage.on "scene:added", (scene) ->
		scene.on "object:created", (object) ->
			if object.type == "image"
				Object.keys(attributes).forEach (propName) ->
					object.registerProperty propName, attributes[propName]

	return {}

API.meta =
	name: "objectTypeImage"

module.exports = API
