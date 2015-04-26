$ = require "jquery"
applyPropertyMap = require "./apply-property-map"
distanceFrom = require "./distance-from"

moveThreshold = 5

textPropertyMap =
	fontFamily: "fontFamily"
	fontSize: (val) -> ["fontSize", "#{val}px"]
	fontColor: "color"
	bold: (val) -> console.log("bold", val); ["fontWeight", (if val then "bold" else "normal")]
	italic: (val) -> ["fontStyle", (if val then "italic" else "normal")]

attachRenderer = (jqObject) ->
	renderer =
		stage: this
		jqObject: jqObject

	console.log renderer.stage

	renderer.stage.on "scene:added", (scene) ->
		scene.on "object:created", (object) ->
			if object.type == "text"
				domElement = $("<div></div>")

				object.on "changed:text", (text) ->
					domElement.text(text)

				object.on "changed:html", (html) ->
					domElement.html(html)

				applyPropertyMap textPropertyMap, object, domElement
			else if object.type == "image"
				domElement = $("<img>")

				object.on "changed:source", (source) ->
					domElement.attr "src", source

			domElement.appendTo jqObject
			domElement.addClass "rendererObject"
			domElement.data "uuid", object.uuid
			domElement.data "scene-uuid", scene.uuid

			object.domElement = domElement

			domElement.on "mousedown", (event) ->
				scene.setActiveObject(object.uuid)
				event.preventDefault()
				event.stopPropagation()

				element = $(this)

				dragging = false
				startPosition = x: event.pageX, y: event.pageY
				startOffset = x: (event.pageX - element.offset().left), y: (event.pageY - element.offset().top)

				$(document).one "mouseup", (event) ->
					$(document).off "mousemove.htmlRenderer"

				$(document).on "mousemove.htmlRenderer", (event) ->
					if distanceFrom(startPosition.x, startPosition.y, event.pageX, event.pageY) >= moveThreshold
						dragging = true

					if dragging
						# FIXME: Set properties on the object instead
						object.x = (event.pageX - startOffset.x)
						object.y = (event.pageY - startOffset.y)

			object.on "changed:x", (x) ->
				domElement.offset left: x

			object.on "changed:y", (y) ->
				domElement.offset top: y

		scene.on "object:switched", (object) ->
			renderer.jqObject
				.find ".rendererObject"
				.removeClass "activated"
				.filter (i, obj) -> ($(obj).data("uuid") == object.uuid)
				.addClass "activated"

		scene.on "object:removed", (object) ->
			object.domElement.remove()

	renderer.stage.on "scene:switched", (scene) ->
		renderer.jqObject
			.find ".rendererObject"
			.hide()
			.filter (i, obj) -> $(obj).data("scene-uuid") == scene.uuid
			.show()

	return renderer

API = (stage) ->
	return {
		attach: attachRenderer.bind(stage)
	}

API.meta =
	name: "htmlRenderer"

module.exports = API
