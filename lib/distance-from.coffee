module.exports = (x1, y1, x2, y2) ->
	deltaX = Math.abs(x2 - x1)
	deltaY = Math.abs(y2 - y1)

	return Math.sqrt((deltaX ** 2) + (deltaY ** 2))