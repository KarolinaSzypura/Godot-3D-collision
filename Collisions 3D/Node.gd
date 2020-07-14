extends Spatial

var collision = false

var minX = 0
var minY = 0
var minZ = 0
var maxX = 0
var maxY = 0
var maxZ = 0

func _ready():
	$Object_1.mesh.material = $Object_1.mesh.material.duplicate()
	$Object_2.mesh.material = $Object_2.mesh.material.duplicate()
	
	check_collision($Object_1, $Object_2)
	
	var data_structure = $Object_1.mesh.surface_get_arrays(0)
	var vertex_array = data_structure[0]
	var normal_array = data_structure[1]
	
	print($Object_2.mesh.surface_get_arrays(0)[1])
	
	$Object_1/ImmediateGeometry.begin(Mesh.PRIMITIVE_LINES)
	for i in vertex_array.size():
		$Object_1/ImmediateGeometry.set_normal(normal_array[i])
#        $ImmediateGeometry.set_uv(uv_array[i])
		$Object_1/ImmediateGeometry.add_vertex(vertex_array[i])
	$Object_1/ImmediateGeometry.end()

func _process(delta):
	process_input()
	
	check_collision($Object_1, $Object_2)
	
	if(collision):
		print("kolizja")
		$Object_1.mesh.material.set("albedo_color", Color.red)
	else:
		$Object_1.mesh.material.set("albedo_color", Color.green)

func check_collision(Obj_1:MeshInstance, Obj_2:MeshInstance):
	var data_structure_1 = $Object_1.mesh.surface_get_arrays(0)
	var data_structure_2 = $Object_2.mesh.surface_get_arrays(0)
	

	
#	print(data_structure_1[0])
	
	var walls = data_structure_1[0]
#	print(" ")
	#wszystkie ściany figury, którą poruszamy
	for i in 6:
		var vertex_1 = walls[(i*4)]
		var vertex_2 = walls[(i*4)+1]
		var vertex_3 = walls[(i*4)+2]
		var vertex_4 = walls[(i*4)+3]
#		print(vertex_1, " ", vertex_2, " ", vertex_3, " ", vertex_4)
		var plane = Plane(vertex_1, vertex_2, vertex_3)
		setMinAndMax(vertex_1, vertex_2, vertex_3, vertex_4)
#		print(wall)
		#wszystkie proste figury, która jest statyczna
#		for line in data_structure_2[2]:
##			print(line_2)
#			var normal = plane.normal
#			print(line)
#			#obliczenia zgodne z algorytmem
#			var NormalDotLine = normal.dot(line)
#			var NormalDotPoint = normal.dot(vertex_1)
#			if (NormalDotLine != 0):
#				var T = - (plane.d + NormalDotPoint) / NormalDotLine
#				if (T > 0):
#					var PunktPrzeciecia = vertex_1 + line * T
#
#					#sprawdzenie czy punkt zawiera się w płaszczyźnie oraz w odcinku
#					if (PunktPrzeciecia.x <= maxX && PunktPrzeciecia.y <= maxY && PunktPrzeciecia.z <= maxZ &&
#						PunktPrzeciecia.x >= minX && PunktPrzeciecia.y >= minY && PunktPrzeciecia.z >= minZ) :
#						collision = true
##						print("Dobrze: ", point_1, " przeciecie: ", PunktPrzeciecia)
#						return true
#					else:
#						collision = false
##						print("point1: ", point_1," T: ", T, " prosta: ", line, " przeciecie: ", PunktPrzeciecia)
##						print("zły punkt, punkt:", PunktPrzeciecia, " min:", minX," ", minY," ", minZ," max: ", maxX," ", maxY," ", maxZ)
#				else:
#					collision = false
##					print("T")
#			else:
#				collision = false
##				print("zero")


func setPoints(Obj_1:CSGPolygon):
	var points = Array()
	for i in Obj_1.polygon.size():
		var point_1 = Vector3(Obj_1.polygon[i].x, Obj_1.polygon[i].y, 0) + Obj_1.translation
		Obj_1.rotation_degrees
		points.push_back(point_1)
	var edge_1 = points[0] - points[1]
	var edge_2 = points[2] - points[1]
	var normal = edge_1.cross(edge_2)
	points.push_back(points[0] - normal)
	points.push_back(points[1] - normal)
	points.push_back(points[2] - normal)
	points.push_back(points[3] - normal)
	return points

#func rownanie_plaszczyzny(point_1, point_2, point_3):
#	var plaszczyzna = Plane(point_1, point_2, point_3)
#	var rownanie = Array()
#	rownanie.push_back(plaszczyzna.x)
#	rownanie.push_back(plaszczyzna.y)
#	rownanie.push_back(plaszczyzna.z)
#	rownanie.push_back(plaszczyzna.d)
#	return rownanie
	
func setMinAndMax(point_1, point_2, point_3, point_4):
	minX = min(point_1.x,min(point_2.x,min(point_3.x,point_4.x)))
	minY = min(point_1.y,min(point_2.y,min(point_3.y,point_4.y)))
	minZ = min(point_1.z,min(point_2.z,min(point_3.z,point_4.z)))
	maxX = max(point_1.x,max(point_2.x,max(point_3.x,point_4.x)))
	maxY = max(point_1.y,max(point_2.y,max(point_3.y,point_4.y)))
	maxZ = max(point_1.z,max(point_2.z,max(point_3.z,point_4.z)))

func rotationMatrix(a, b, c):
	var matrix = Basis()
	matrix = [Vector3(cos(a)*cos(c) - sin(a)*sin(c)*cos(b), -cos(a)*sin(c) - sin(a)*cos(c)*cos(b), sin(a)*sin(b)), 
			Vector3(sin(a)*cos(c) + cos(a)*sin(c)*cos(b), -sin(a)*sin(c) + cos(a)*cos(c)*cos(b), -cos(a)*sin(b)), 
			Vector3(sin(c)*sin(b), cos(c)*sin(b), cos(b))]
	return matrix

func process_input():
	if InputEventMouse:
		if Input.is_action_pressed("mouse_lb_pressed"):
			var mouse = get_viewport().get_mouse_position()
			var z = $Object_1.translation.z
			var dropPlane  = Plane(Vector3(0, 0, 1), z)
			var position3D = dropPlane.intersects_ray($Camera.project_ray_origin(mouse),$Camera.project_ray_normal(mouse))
			$Object_1.translation = lerp($Object_1.translation, position3D, 0.1)

		if Input.is_action_pressed("x"):
			$Object_1.rotation += Vector3(0.1,0,0)
		if Input.is_action_pressed("c"):
			$Object_1.rotation += Vector3(0,0.1,0)
		if Input.is_action_pressed("z"):
			$Object_1.rotation += Vector3(0,0,0.1)
		
		if Input.is_action_just_released("ui_up"):
			$Object_1.translation += Vector3(0, 0, -0.1)
			
		if Input.is_action_just_released("ui_down"):
			$Object_1.translation += Vector3(0, 0, 0.1)
		
		if Input.is_action_just_released("ui_left"):
			$Object_1.translation += Vector3(-0.1, 0, 0)
			
		if Input.is_action_just_released("ui_right"):
			$Object_1.translation += Vector3(0.1, 0, 0)
