uuid = require "uuid"
EventEmitter = require("events").EventEmitter
splitFilter = require "../lib/split-filter"

sceneNameIncrement = 1
objectNameIncrement = 1

class AuthoredObject extends EventEmitter
	constructor: (@scene, options = {}) ->
		@uuid = uuid.v4()
		@_props = {}
		@propMeta = {}

		@registerInternalProperty "visible", true
		@registerInternalProperty "editorVisible", true
		@registerInternalProperty "editorFaded", false

		if not options.name?
			name = "Object #{objectNameIncrement++}"
		else
			name = options.name

		@registerInternalProperty "name", name
		@registerInternalProperty "type"

		@registerProperty "x", type: "numeric"
		@registerProperty "y", type: "numeric"

		if options.type?
			@type = options.type

	registerInternalProperty: (propName, defaultValue) ->
		@registerProperty(propName, null)

		if defaultValue?
			this[propName] = defaultValue

	registerProperty: (propName, propMeta) ->
		Object.defineProperty this, propName,
			enumerable: true
			get: => @_props[propName]
			set: (value) =>
				@_props[propName] = value
				@emit "changed:#{propName}", @_props[propName], this
				@emit "changed", propName, @_props[propName], this

		# Explicitly allow specifying `null` for propMeta to avoid propMeta; this is used for internal properties.
		if propMeta == undefined
			@propMeta[propName] = {}
		else if propMeta != null
			@propMeta[propName] = propMeta

class AuthoredScene extends EventEmitter
	constructor: (@stage, options = {}) ->
		@uuid = uuid.v4()
		@objects = {}
		@orderedObjects = []
		@activeObject = null
		@_ignoredProperties = ["orderedObjects"]

		if not options.name?
			@name = "Scene #{sceneNameIncrement++}"
		else
			@name = options.name

	_startAddObject: (object) ->
		@objects[object.uuid] = object
		@orderedObjects.push object
		object.scene = this

	_endAddObject: (object) ->
		@emit "object:added", object

	setName: (name) ->
		@name = name

	createObject: (options = {}) ->
		newObject = new AuthoredObject(this, options)
		@_startAddObject(newObject)

		if options.autoActivate ? true
			process.nextTick =>
				@setActiveObject newObject.uuid

		@emit "object:created", newObject
		@_endAddObject(newObject)

	addObject: (object) ->
		@_startAddObject(object)
		@_endAddObject(object)

	removeObject: (uuid) ->
		objectIndex = @orderedObjects.indexOf(@objects[uuid])

		delete @objects[uuid]

		[@orderedObjects, removedObjects] = splitFilter @orderedObjects, (object) ->
			object.uuid != uuid

		removedObjects.forEach (object) =>
			@emit "object:removed", object

		if objectIndex == 0
			newActiveIndex = 0
		else
			newActiveIndex = objectIndex - 1

		@setActiveObject(@orderedObjects[newActiveIndex]?.uuid)

	getActiveObject: ->
		return @objects[@activeObject]

	setActiveObject: (uuid) ->
		@activeObject = uuid
		@emit "object:switched", @objects[uuid]

	getObjectNameIncrement: ->
		return objectNameIncrement++


module.exports = class AuthoredStage extends EventEmitter
	constructor: (options = {}) ->
		@plugins = []
		@scenes = {}
		@orderedScenes = []
		@activeScene = null

		process.nextTick =>
			# Initial scene
			@createScene()

	use: (plugin) ->
		pluginMeta = plugin.meta

		# Verify that all dependencies exist...
		if Array.isArray pluginMeta.dependencies
			pluginMeta.dependencies.forEach (dep) =>
				if not @plugins[dep]?
					# FIXME: DependencyError
					throw new Error "Unmet dependency: `#{pluginMeta.name}` requires `#{dep}`"
		else if typeof pluginMeta.dependencies == "function"
			pluginMeta.dependencies(this)

		pluginAPI = plugin(this)

		# In case of misbehaving plugins...
		pluginAPI ?= {}

		@plugins[pluginMeta.name] = pluginAPI

	createScene: (options = {}) ->
		newScene = new AuthoredScene(this, options)
		@scenes[newScene.uuid] = newScene
		@orderedScenes.push newScene

		if options.autoActivate ? true
			process.nextTick =>
				@setActiveScene newScene.uuid

		@emit "scene:added", newScene

	removeScene: (uuid) ->
		sceneIndex = @orderedScenes.indexOf(@scenes[uuid])

		delete @scenes[uuid]

		[@orderedScenes, removedScenes] = splitFilter @orderedScenes, (scene) ->
			scene.uuid != uuid

		removedScenes.forEach (scene) =>
			@emit "scene:removed", scene

		if sceneIndex == 0
			newActiveIndex = 0
		else
			newActiveIndex = sceneIndex - 1

		@setActiveScene(@orderedScenes[newActiveIndex]?.uuid)

	getActiveScene: ->
		return @scenes[@activeScene]

	setActiveScene: (uuid) ->
		@activeScene = uuid
		@emit "scene:switched", @scenes[uuid]

