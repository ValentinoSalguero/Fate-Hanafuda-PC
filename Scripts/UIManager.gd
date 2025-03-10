extends Node

var contenedor_cartas : Node

func _ready():
	contenedor_cartas = $ContenedorCartas

func mostrar_cartas():
	# Asegurarse de que las cartas ya hayan sido repartidas y mostradas antes de llamar a esta función
	for i in range(get_node("/root/GameController").jugadores[0].mano.size()):
		var carta = get_node("/root/GameController").jugadores[0].mano[i]
		var sprite = Sprite2D.new()
		# Asumiendo que cada carta ya tiene la imagen asociada al nombre del mes y valor
		sprite.texture = load("res://Imagenes/" + carta.mes + str(carta.valor) + ".png")
		# Ajustar la posición en pantalla para que no se sobrepongan
		sprite.position = Vector2(100 * i, 300)
		contenedor_cartas.add_child(sprite)
