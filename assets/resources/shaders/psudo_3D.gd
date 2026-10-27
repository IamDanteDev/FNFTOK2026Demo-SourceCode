extends Sprite2D
@export var isStaticObject: bool = true
@export var ObjectWeight: float

@export var VertexTopLeftWeight: float
@export var VertexTopRightWeight: float
@export var VertexBottomLeftWeight: float
@export var VertexBottomRightWeight: float

var camera_y_base: float
var camera_x_base: float
var shader_amount_x: float
var shader_amount_y: float

var set_paramerters: bool

@onready var stage = $"../.."
@onready var init_scale = scale

func _ready():
	set_paramerters = false

func _process(delta):
	camera_y_base = Event.cam_pos.y
	camera_x_base = Event.cam_pos.x


	var screenPos = Event.screen_pos
	shader_amount_x = - screenPos.x + camera_x_base
	shader_amount_y = - screenPos.y + camera_y_base

	if isStaticObject:
		var offsetx = shader_amount_x * ObjectWeight
		var offsety = shader_amount_y * ObjectWeight
		self.offset = Vector2(offsetx, offsety)
	else:
		if set_paramerters == false:


			material.set_shader_parameter("vertex1", VertexTopLeftWeight)
			material.set_shader_parameter("vertex2", VertexTopRightWeight)
			material.set_shader_parameter("vertex3", VertexBottomLeftWeight)
			material.set_shader_parameter("vertex4", VertexBottomRightWeight)

			set_paramerters = true

		material.set_shader_parameter("amtx", shader_amount_x)
		material.set_shader_parameter("amty", shader_amount_y)
