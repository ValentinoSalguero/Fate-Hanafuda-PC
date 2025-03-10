extends Node2D

var mes : String = ""
var valor : int = 0
var sprite : Sprite2D

func _ready():
	sprite = $Sprite2D
	sprite.texture = load("res://Images/Dorso.png") # Cargar el dorso inicialmente
	scale = Vector2(0.7, 0.7)

func inicializar(nuevo_mes : String, nuevo_valor : int):
	mes = nuevo_mes
	valor = nuevo_valor

func mostrar_frente():
	if sprite and mes != "" and valor > 0:
		var ruta = "res://Images/Cards/" + mes + str(valor) + ".png"
		if ResourceLoader.exists(ruta):
			sprite.texture = load(ruta)
		else:
			print("Imagen no encontrada: ", ruta)
