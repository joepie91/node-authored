$ = require "jquery"
domWait = require "../lib/dom-wait"

# Scene panel functions
createObjectItem = (uuid, name, sceneUuid) ->
	list = @jqObject.find "ul.objectList"

	$("<li></li>")
		.appendTo list
		.data "uuid", uuid
		.data "scene-uuid", sceneUuid
		.text name

removeObjectItem = (uuid) ->
	@jqObject
		.find "ul.objectList li"
		.filter (i, li) -> $(li).data("uuid") == uuid
		.remove()

switchObjectItem = (uuid) ->
	@jqObject
		.find "ul.objectList li"
		.removeClass "selected"
		.filter (i, li) -> $(li).data("uuid") == uuid
		.addClass "selected"

# API methods
attachObjectPanel = (jqObject) ->
	panel =
		stage: this
		jqObject: jqObject
		createObjectItem: domWait.func(createObjectItem)
		removeObjectItem: domWait.func(removeObjectItem)
		switchObjectItem: domWait.func(switchObjectItem)

	panel.stage.on "scene:added", (scene) ->

		scene.on "object:added", (object) ->
			domElement = panel.createObjectItem(object.uuid, object.name, scene.uuid)
			# FIXME: For now assumes that we automatically activate the new object.
			panel.switchObjectItem(object.uuid)

			object.on "changed:editorFaded", (faded) ->
				if faded
					domElement.addClass "faded"
				else
					domElement.removeClass "faded"

		scene.on "object:removed", (object) ->
			panel.removeObjectItem(object.uuid)

		scene.on "object:switched", (object) ->
			panel.switchObjectItem(object.uuid)

	panel.stage.on "scene:switched", (scene) ->
		jqObject
			.find "ul.objectList li"
			.hide()
			.filter (i, li) -> $(li).data("scene-uuid") == scene.uuid
			.show()

		if activeObject = scene.getActiveObject?()
			panel.switchObjectItem activeObject.uuid

	jqObject
		.find ".action-addObject"
		.on "click", (event) ->
			activeScene = panel.stage.getActiveScene()
			objectType = $(this).data("type")
			objectName = "Object (#{objectType}) #{activeScene.getObjectNameIncrement()}"
			newObject = activeScene.createObject(type: objectType, name: objectName)

	jqObject
		.find ".action-removeObject"
		.on "click", (event) ->
			activeScene = panel.stage.getActiveScene()
			targetUuid = activeScene.getActiveObject().uuid
			newObject = activeScene.removeObject(targetUuid)

	jqObject
		.find "ul.objectList"
		.on "mousedown", "li", (event) ->
			targetUuid = $(this).data "uuid"
			activeScene = panel.stage.getActiveScene()
			activeScene.setActiveObject targetUuid

# Public API
API = (stage) ->
	return {
		attach: attachObjectPanel.bind(stage)
	}

API.meta =
	name: "objectPanel"

module.exports = API
