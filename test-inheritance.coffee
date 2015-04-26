class A
	constructor: ->

	someMethod: ->
		console.log "a"

	someOtherMethod: ->
		console.log "2"

b = new A()
b.someMethod()

c = Object.create(b)

c.someMethod = ->
	console.log "derp"

c.someMethod()
b.someMethod()

d = Object.create(c)
d.someMethod()
d.someOtherMethod()
