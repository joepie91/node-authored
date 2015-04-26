$ = require "jquery"
domWait = require "../lib/dom-wait"

# Layer panel functions
createLayerItem = (uuid, name, sceneUuid) ->
	list = @jqObject.find "ul.layerList"

	$("<li></li>")
		.appendTo list
		.data "uuid", uuid
		.data "scene-uuid", sceneUuid
		.text name

removeLayerItem = (uuid) ->
	@jqObject
		.find "ul.layerList li"
		.filter (i, li) -> $(li).data("uuid") == uuid
		.remove()

switchLayerItem = (uuid) ->
	@jqObject
		.find "ul.layerList li"
		.removeClass "selected"
		.filter (i, li) -> $(li).data("uuid") == uuid
		.addClass "selected"

# API methods
attachLayerPanel = (jqObject) ->
	panel =
		stage: this
		jqObject: jqObject
		createLayerItem: domWait.func(createLayerItem)
		removeLayerItem: domWait.func(removeLayerItem)
		switchLayerItem: domWait.func(switchLayerItem)

	panel.stage.on "scene:added", (scene) ->
		scene.on "layer:added", (layer) ->
			panel.createLayerItem(layer.uuid, layer.name, scene.uuid)
			# FIXME: For now assumes that we automatically activate the new layer.
			panel.switchLayerItem(layer.uuid)

		scene.on "layer:removed", (layer) ->
			panel.removeLayerItem(layer.uuid)

		scene.on "layer:switched", (layer) ->
			if layer?
				panel.switchLayerItem(layer.uuid)

	panel.stage.on "scene:switched", (scene) ->
		jqObject
			.find "ul.layerList li"
			.hide()
			.filter (i, li) -> $(li).data("scene-uuid") == scene.uuid
			.show()

		if activeLayer = scene.getActiveLayer?()
			panel.switchLayerItem activeLayer.uuid

	jqObject
		.find ".action-addLayer"
		.on "click", (event) ->
			activeScene = panel.stage.getActiveScene()
			activeScene.createLayer()

	jqObject
		.find ".action-removeLayer"
		.on "click", (event) ->
			targetUuid = panel.stage.getActiveScene().getActiveLayer().uuid
			panel.stage.getActiveScene().removeLayer targetUuid

	jqObject
		.find "ul.layerList"
		.on "mousedown", "li", (event) ->
			targetUuid = $(this).data "uuid"
			panel.stage.getActiveScene().setActiveLayer targetUuid

# Public API
API = (stage) ->
	return {
		attach: attachLayerPanel.bind(stage)
	}

API.meta =
	name: "layerPanel"
	dependencies: ["layers"]

module.exports = API
