extends TextureRect

const WIDTH := 300
const HEIGHT := 140

func change_frame(frame: Vector2):
	texture.region.position.x = frame.x * WIDTH
	texture.region.position.y = frame.y * HEIGHT
