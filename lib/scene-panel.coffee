$ = require "jquery"
domWait = require "../lib/dom-wait"

# Scene panel functions
createSceneItem = (uuid, name) ->
	list = @jqObject.find "ul.sceneList"

	$("<li></li>")
		.appendTo list
		.data "uuid", uuid
		.text name

removeSceneItem = (uuid) ->
	@jqObject
		.find "ul.sceneList li"
		.filter (i, li) -> $(li).data("uuid") == uuid
		.remove()

switchSceneItem = (uuid) ->
	@jqObject
		.find "ul.sceneList li"
		.removeClass "selected"
		.filter (i, li) -> $(li).data("uuid") == uuid
		.addClass "selected"

# API methods
attachScenePanel = (jqObject) ->
	panel =
		stage: this
		jqObject: jqObject
		createSceneItem: domWait.func(createSceneItem)
		removeSceneItem: domWait.func(removeSceneItem)
		switchSceneItem: domWait.func(switchSceneItem)

	panel.stage.on "scene:added", (scene) ->
		panel.createSceneItem(scene.uuid, scene.name)
		# FIXME: For now assumes that we automatically activate the new scene.
		panel.switchSceneItem(scene.uuid)

	panel.stage.on "scene:removed", (scene) ->
		panel.removeSceneItem(scene.uuid)

	panel.stage.on "scene:switched", (scene) ->
		panel.switchSceneItem(scene.uuid)

	jqObject
		.find ".action-addScene"
		.on "click", (event) ->
			activeScene = panel.stage.createScene()

	jqObject
		.find ".action-removeScene"
		.on "click", (event) ->
			targetUuid = panel.stage.getActiveScene().uuid
			panel.stage.removeScene targetUuid

	jqObject
		.find "ul.sceneList"
		.on "mousedown", "li", (event) ->
			targetUuid = $(this).data "uuid"
			panel.stage.setActiveScene targetUuid

# Public API
API = (stage) ->
	return {
		attach: attachScenePanel.bind(stage)
	}

API.meta =
	name: "scenePanel"

module.exports = API
