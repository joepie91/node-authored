$ = require "jquery"
domWait = require "../lib/dom-wait"

lockTimeout = 500

# Property panel functions
createPropertyItem = (name, type) ->
	list = @jqObject.find "div.propertyList"
	object = @stage.getActiveScene().getActiveObject()

	# To prevent our changes from echoing
	lastValue = null

	domElement = $("<div class='property'><label></label></div>")
		.data "property", name
		.data "type", type
		.appendTo list

	domElement
		.children "label"
		.text name

	setValue = (value) ->
		if value == lastValue
			return

		lastValue = value

		property = domElement.data("property")
		object[property] = value

	if type == "boolean"
		# Checkboxes want to be special.
		inputElement = $("<input type='checkbox'>")

		inputElement
			.prop "checked", object[name]
			.on "change", (event) ->
				setValue $(this).is ":checked"

		object.on "changed:#{name}", (value) ->
			if value == lastValue
				return

			lastValue = value
			inputElement.prop "checked", value
	else
		inputElement = switch type
			when "numeric"
				$("<input type='numeric'>")
			when "text"
				$("<input type='text'>")
			else
				$("<input type='text'>")

		inputElement
			.val object[name]
			.on "change input propertychange", (event) ->
				setValue $(this).val()

		object.on "changed:#{name}", (value) ->
			if value == lastValue
				return

			lastValue = value
			inputElement.val(value)

	inputElement.appendTo domElement

removePropertyItems = (uuid) ->
	@jqObject
		.find "div.propertyList .property"
		.remove()

# API methods
attachPropertyPanel = (jqObject) ->
	panel =
		stage: this
		jqObject: jqObject
		createPropertyItem: domWait.func(createPropertyItem)
		removePropertyItems: domWait.func(removePropertyItems)

	panel.stage.on "scene:added", (scene) ->
		scene.on "object:switched", (object) ->
			panel.removePropertyItems()

			Object.keys(object.propMeta).forEach (property) ->
				meta = object.propMeta[property]
				console.log property, meta
				panel.createPropertyItem property, meta.type

# Public API
API = (stage) ->
	return {
		attach: attachPropertyPanel.bind(stage)
	}

API.meta =
	name: "propertyPanel"

module.exports = API
