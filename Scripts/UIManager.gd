extends Node

var contenedor_cartas : Node

func _ready():
	contenedor_cartas = $ContenedorCartas

func mostrar_cartas():
	for i in range(get_node("/root/GameController").jugadores[0].mano.size()):
		var carta = get_node("/root/GameController").jugadores[0].mano[i]
		var sprite = Sprite2D.new()
		sprite.texture = load("res://Imagenes/" + carta.mes + str(carta.valor) + ".png")
		sprite.position = Vector2(100 * i, 300)
		contenedor_cartas.add_child(sprite)
