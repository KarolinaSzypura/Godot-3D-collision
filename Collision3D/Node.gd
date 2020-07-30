extends Spatial

var collision = false

var points_1 = Array()
var points_2 = Array()

#					przód		lewa	dół			góra	prawa		tył
var walls_index = [[0,3,2,1],[0,1,5,4],[0,4,7,3],[1,2,6,5],[3,7,6,2],[5,6,7,4]]
var lines_index = [[0,1],[1,2],[3,2],[0,3],[0,4],[1,5],[2,6],[3,7],[4,5],[5,6],[7,6],[4,7]]

var minPX = 0
var minPY = 0
var minPZ = 0
var maxPX = 0
var maxPY = 0
var maxPZ = 0


func _ready():
	$Object_1.material = $Object_1.material.duplicate()
	$Object_2.material = $Object_2.material.duplicate()
	points_2 = setPoints($Object_2)
	
	check_collision($Object_1, $Object_2)

func _process(delta):
	process_input()
	
	check_collision($Object_1, $Object_2)
	
	if(collision):
#		print("kolizja")
		$Object_1.material.set("albedo_color", Color.red)
	else:
		$Object_1.material.set("albedo_color", Color.green)


func check_collision(Obj_1:CSGPolygon, Obj_2:CSGPolygon):
	points_1 = setPoints(Obj_1)
	
	#wszystkie ściany figury, którą poruszamy
	for wall_1 in walls_index:
		var plane_1 = Plane(points_1[wall_1[0]], points_1[wall_1[1]], points_1[wall_1[3]])
		#wszystkie proste figury, która jest statyczna
		for line_2 in lines_index:
			var point_1 = points_2[line_2[0]]
			var point_2 = points_2[line_2[1]]

			#ustawienie granic odcinka, aby później sprawdzić czy punkt leży na krawędzi czy poza nią
			setMaxAndMinOfEdge(point_1, point_2)

			#prosta (przedłużenine krawędzi) i normalna do płaszczyzny
			var line = point_2 - point_1
			var normal = plane_1.normal

			#obliczenia zgodne z algorytmem
			var NormalDotLine = normal.dot(line)
			var NormalDotPoint = normal.dot(point_1 - points_1[wall_1[0]])
			if (NormalDotLine != 0):
				var T = - (NormalDotPoint) / NormalDotLine
				var PunktPrzeciecia = point_1 + line * T

				#sprawdzenie czy punkt zawiera się w płaszczyźnie oraz w odcinku
				if (isInsideWall(PunktPrzeciecia, points_1[wall_1[0]], points_1[wall_1[1]], points_1[wall_1[2]], points_1[wall_1[3]]) &&
					PunktPrzeciecia.x <= maxPX && PunktPrzeciecia.y <= maxPY && PunktPrzeciecia.z <= maxPZ &&
					PunktPrzeciecia.x >= minPX && PunktPrzeciecia.y >= minPY && PunktPrzeciecia.z >= minPZ) :
					collision = true
					return true
				else:
					collision = false
			else:
				collision = false

#odwrotna sytuacja: dla figury statycznej ściany, a dla dynamicznej krawędzie
	#wszystkie ściany figury, która jest statyczna
	for wall_2 in walls_index:
#		var rownanie_1 = rownanie_plaszczyzny(points_1[sciana_1[0]], points_1[sciana_1[1]], points_1[sciana_1[2]])
		var plane_2 = Plane(points_2[wall_2[0]], points_2[wall_2[1]], points_2[wall_2[3]])
		#wszystkie proste figury, która jest statyczna
		for line_1 in lines_index:
			var point_1 = points_1[line_1[0]]
			var point_2 = points_1[line_1[1]]

			#granice odcinka
			setMaxAndMinOfEdge(point_1, point_2)

			#prosta i normalna do płaszczyzny
			var line = point_2 - point_1
			var normal = plane_2.normal

			#obliczenia zgodne z algorytmem
			var NormalDotLine = normal.dot(line)
			var NormalDotPoint = normal.dot(point_1 - points_2[wall_2[0]])
			if (NormalDotLine != 0):
				var T = - NormalDotPoint / NormalDotLine
				var PunktPrzeciecia = point_1 + line * T

				#sprawdzenie czy punkt zawiera się w płaszczyźnie oraz w odcinku
				if (isInsideWall(PunktPrzeciecia,points_2[wall_2[0]], points_2[wall_2[1]], points_2[wall_2[2]], points_2[wall_2[3]]) &&
					PunktPrzeciecia.x <= maxPX && PunktPrzeciecia.y <= maxPY && PunktPrzeciecia.z <= maxPZ &&
					PunktPrzeciecia.x >= minPX && PunktPrzeciecia.y >= minPY && PunktPrzeciecia.z >= minPZ) :
					collision = true
					return true
				else:
					collision = false
			else:
				collision = false

func setPoints(Obj_1:CSGPolygon):
	var points = Array()
	for i in Obj_1.polygon.size():
		var point_1 = Vector3(Obj_1.polygon[i].x, Obj_1.polygon[i].y, 0)
		point_1 = rotation(point_1, Obj_1.rotation_degrees.x, "X")
		point_1 = rotation(point_1, Obj_1.rotation_degrees.y, "Y")
		point_1 = rotation(point_1, Obj_1.rotation_degrees.z, "Z")
		point_1 = point_1 + Obj_1.translation
		points.push_back(point_1)
	var edge_1 = points[0]-points[1]
	var edge_2 = points[2]-points[1]
	var normal = edge_1.cross(edge_2)
	normal = normal.normalized()
	points.push_back(points[0] - normal)
	points.push_back(points[1] - normal)
	points.push_back(points[2] - normal)
	points.push_back(points[3] - normal)
	return points

func setMaxAndMinOfEdge(point_1, point_2):
	minPX = min(point_1.x,point_2.x)
	minPY = min(point_1.y,point_2.y)
	minPZ = min(point_1.z,point_2.z)
	maxPX = max(point_1.x,point_2.x)
	maxPY = max(point_1.y,point_2.y)
	maxPZ = max(point_1.z,point_2.z)

func rotation(actual_point, degree, axis):
	var rotationMatrix
	var q = deg2rad(degree)
	match axis:
		"X":
			rotationMatrix = 	[Vector3(	1,	0,		0), 
								Vector3(	0, 	cos(q), -sin(q)), 
								Vector3(	0,	sin(q), cos(q))]
		"Y":
			rotationMatrix = 	[Vector3(	cos(q), 0, 	sin(q)), 
								Vector3(	0,		1,	0), 
								Vector3(	-sin(q), 0, cos(q))]
		"Z":
			rotationMatrix = 	[Vector3(	cos(q), -sin(q),0), 
								Vector3(	sin(q), cos(q), 0), 
								Vector3(	0,		0,		1)]
	actual_point = Dot(rotationMatrix, actual_point)
	return actual_point

func Dot(matrix, point):
	var vec1 = matrix[0]
	var vec2 = matrix[1]
	var vec3 = matrix[2]
	var out = Vector3()
	out.x = vec1.dot(point)
	out.y = vec2.dot(point)
	out.z = vec3.dot(point)
	return out

func isInsideWall(testPoint, point_1, point_2, point_3, point_4):
	var V1 = (testPoint - point_1).cross(point_2 - point_1)
	var V2 = (testPoint - point_2).cross(point_3 - point_2)
	var V3 = (testPoint - point_3).cross(point_4 - point_3)
	var V4 = (testPoint - point_4).cross(point_1 - point_4)
	if( V1.dot(V2) >= 0 && V2.dot(V3) >= 0 && V3.dot(V4) >= 0 && V4.dot(V1) >= 0):
		return true
	else:
		return false

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
