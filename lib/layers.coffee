uuid = require "uuid"
splitFilter = require "../lib/split-filter"

nameIncrement = 1

# Scene methods
createLayer = (options = {}) ->
	if not options.name?
		name = "Layer #{nameIncrement++}"
	else
		name = options.name

	newUuid = uuid.v4()

	layerObject =
		name: name
		uuid: newUuid
		scene: this

	@layers[newUuid] = layerObject
	@orderedLayers.push layerObject

	if options.autoActivate ? true
		@setActiveLayer(newUuid)

	@emit "layer:added", layerObject

	return layerObject

removeLayer = (uuid) ->
	# FIXME: Edge-case: removing the last layer in a scene?
	layerIndex = @orderedLayers.indexOf(@layers[uuid])

	delete @layers[uuid]

	[@orderedLayers, removedLayers] = splitFilter @orderedLayers, (layer) ->
		layer.uuid != uuid

	removedLayers.forEach (layerObject) =>
		@emit "layer:removed", layerObject

	# Remove all the objects on this layer as well...
	@orderedObjects
		.filter (object) -> object.layer == uuid
		.forEach (object) => @removeObject(object.uuid)

	if layerIndex == 0
		newActiveIndex = 0
	else
		newActiveIndex = layerIndex - 1

	@setActiveLayer(@orderedLayers[newActiveIndex]?.uuid)

setActiveLayer = (uuid) ->
	@activeLayer = uuid

	@orderedObjects.forEach (object) ->
		object.editorFaded = (object.layer != uuid)

	@emit "layer:switched", @layers[uuid]

getActiveLayer = ->
	return @layers[@activeLayer]

# Object methods
setLayer = (uuid) ->
	@emit "layer:switched", @scene.layers[uuid]
	@layer = uuid

# Setup function
API = (stage) ->
	stage.on "scene:added", (scene) ->
		scene._ignoredProperties.push "orderedLayers"

		scene.layers = {}
		scene.orderedLayers = []

		scene.createLayer = createLayer
		scene.removeLayer = removeLayer
		scene.setActiveLayer = setActiveLayer
		scene.getActiveLayer = getActiveLayer

		scene.on "object:added", (object) ->
			object.layer = scene.activeLayer
			object.setLayer = setLayer

		scene.on "object:switched", (object) ->
			if object.layer?
				scene.setActiveLayer(object.layer)

		process.nextTick ->
			# Default first layer
			scene.createLayer()

	stage.on "scene:removed", (scene) ->
		scene.orderedLayers.forEach (layer) ->
			scene.removeLayer(layer.uuid)

	return {}

API.meta =
	name: "layers"

module.exports = API

# SPEC: list modifier for reordering the objects according to their layer...?
