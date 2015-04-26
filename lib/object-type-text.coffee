attributes =
	text:
		type: "string"
	html:
		type: "html"
	fontFamily:
		type: "font"
	fontSize:
		type: "numeric"
	bold:
		type: "boolean"
	italic:
		type: "boolean"
	fontColor:
		type: "color"

API = (stage) ->
	stage.on "scene:added", (scene) ->
		scene.on "object:created", (object) ->
			if object.type == "text"
				Object.keys(attributes).forEach (propName) ->
					object.registerProperty propName, attributes[propName]

			process.nextTick ->
				object.text = "Text goes here"

	return {}

API.meta =
	name: "objectTypeText"

module.exports = API
