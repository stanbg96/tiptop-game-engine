extends Node3D

@onready var camera = $Camera3D
@onready var joy = $UI/JoystickArea/VirtualJoystick
@onready var chat_log = $UI/ChatBG/VBox/Margin1/Log
@onready var chat_input = $UI/ChatBG/VBox/Margin2/InputRow/ChatInput
@onready var center_tools = $UI/CenterTools
@onready var lbl_selected = $UI/CenterTools/Panel/VBox/Header/LabelName
@onready var indicator = $Indicator
@onready var world = $World
@onready var http_request = $HTTPRequest

# UI елементи за облачния AI
@onready var api_page = $UI/ApiPage
@onready var provider_select = $UI/ApiPage/Card/Margin/VBox/ProviderSelect
@onready var key_input = $UI/ApiPage/Card/Margin/VBox/KeyInput
@onready var test_btn = $UI/ApiPage/Card/Margin/VBox/TestBtn
@onready var status_lbl = $UI/ApiPage/Card/Margin/VBox/StatusLbl
@onready var model_select = $UI/ApiPage/Card/Margin/VBox/ModelSelect
@onready var current_model_chip = $UI/ChatBG/VBox/TopRow/CurrentModelLbl

var selected_obj: Node3D = null
var is_dragging: bool = false
var cam_yaw: float = 0.0
var cam_pitch: float = -0.4

var providers = {
    0: {"name": "OpenRouter", "chat": "https://openrouter.ai/api/v1/chat/completions", "models_url": "https://openrouter.ai/api/v1/models"},
    1: {"name": "Groq", "chat": "https://api.groq.com/openai/v1/chat/completions", "models_url": "https://api.groq.com/openai/v1/models"},
    2: {"name": "OpenAI", "chat": "https://api.openai.com/v1/chat/completions", "models_url": "https://api.openai.com/v1/models"},
    3: {"name": "DeepSeek", "chat": "https://api.deepseek.com/v1/chat/completions", "models_url": "https://api.deepseek.com/v1/models"}
}

var current_provider_idx: int = 0
var api_key: String = ""
var current_model: String = "default"
var fetched_models: Array = []
var is_testing_models: bool = false

func _ready():
    center_tools.visible = false
    indicator.visible = false
    api_page.visible = false
    
    http_request.request_completed.connect(_on_http_response)
    _setup_provider_dropdown()
    _load_saved_config()
    
    _add_log("[color=#00f2fe]✨ TipTop Studio е активно![/color]")
    _add_log("[color=#ffff66]Натисни '⚙️ AI Облак' долу за избор на модели.[/color]")
    
    _build("дърво", Vector3(-3.5, 0.0, -5.0))
    _build("кола", Vector3(3.5, 0.0, -5.0))

func _setup_provider_dropdown():
    provider_select.clear()
    provider_select.add_item("🌐 OpenRouter (300+ модела)")
    provider_select.add_item("⚡ Groq (Супер бърз)")
    provider_select.add_item("🤖 OpenAI (ChatGPT)")
    provider_select.add_item("🧠 DeepSeek (V3 / R1)")

func _process(delta):
    if joy.output.length() > 0.05:
        var fwd = -camera.global_transform.basis.z
        var rgt = camera.global_transform.basis.x
        fwd.y = 0.0
        rgt.y = 0.0
        fwd = fwd.normalized()
        rgt = rgt.normalized()
        camera.global_position += (rgt * joy.output.x + fwd * -joy.output.y) * 14.0 * delta

    if selected_obj and is_instance_valid(selected_obj):
        indicator.visible = true
        var bounce = sin(Time.get_ticks_msec() * 0.006) * 0.25
        indicator.global_position = selected_obj.global_position + Vector3(0, 3.2 + bounce, 0)
    else:
        indicator.visible = false

func _unhandled_input(event):
    if api_page.visible:
        return
        
    var screen_h = get_viewport().size.y
    var limit_h = screen_h * 0.65

    if event is InputEventScreenTouch:
        if event.position.y > limit_h:
            return
        if event.pressed:
            var hit = _raycast(event.position)
            if hit:
                _select(hit)
                is_dragging = true
            else:
                _deselect()
                is_dragging = false
        else:
            is_dragging = false

    elif event is InputEventScreenDrag:
        if event.position.y > limit_h:
            return
        if is_dragging and selected_obj and is_instance_valid(selected_obj):
            var drop = _get_floor(event.position)
            if drop != Vector3.INF:
                selected_obj.global_position.x = drop.x
                selected_obj.global_position.z = drop.z
        else:
            cam_yaw -= event.relative.x * 0.005
            cam_pitch = clamp(cam_pitch - event.relative.y * 0.005, -1.4, 1.4)
            camera.rotation.y = cam_yaw
            camera.rotation.x = cam_pitch

func _raycast(pos: Vector2):
    var from = camera.project_ray_origin(pos)
    var to = from + camera.project_ray_normal(pos) * 1000.0
    var q = PhysicsRayQueryParameters3D.create(from, to)
    var res = get_world_3d().direct_space_state.intersect_ray(q)
    if res and res.collider.is_in_group("prop"):
        return res.collider.get_parent()
    return null

func _get_floor(pos: Vector2):
    var from = camera.project_ray_origin(pos)
    var dir = camera.project_ray_normal(pos)
    var h = selected_obj.global_position.y if selected_obj else 0.0
    var plane = Plane(Vector3.UP, h)
    var hit = plane.intersects_ray(from, dir)
    if hit != null:
        return hit
    return Vector3.INF

func _select(obj):
    selected_obj = obj
    lbl_selected.text = "🎯 " + obj.name
    center_tools.visible = true

func _deselect():
    selected_obj = null
    center_tools.visible = false

func _on_act_up():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.global_position.y += 0.8

func _on_act_down():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.global_position.y = max(0.0, selected_obj.global_position.y - 0.8)

func _on_act_rot():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.rotate_y(deg_to_rad(45.0))

func _on_act_del():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.queue_free()
        _deselect()

func _on_open_settings():
    api_page.visible = true

func _on_close_settings():
    api_page.visible = false
    _save_config()

func _on_provider_selected(idx: int):
    current_provider_idx = idx
    status_lbl.text = "Избран доставчик: " + providers[idx]["name"]
    model_select.clear()
    model_select.add_item("Натисни бутона по-долу за сваляне на модели...")

func _on_fetch_models_pressed():
    api_key = key_input.text.strip_edges()
    if api_key.is_empty():
        status_lbl.text = "❌ Моля, въведи първо API ключ!"
        status_lbl.modulate = Color(1, 0.3, 0.3)
        return

    is_testing_models = true
    test_btn.disabled = true
    status_lbl.text = "⏳ Свързване и сваляне на модели..."
    status_lbl.modulate = Color(1, 0.9, 0.2)

    var url = providers[current_provider_idx]["models_url"]
    var headers = [
        "Authorization: Bearer " + api_key,
        "Content-Type: application/json"
    ]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")
        headers.append("X-Title: TipTop Studio")

    http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    test_btn.disabled = false
    
    if is_testing_models:
        is_testing_models = false
        if response_code == 200:
            var json = JSON.new()
            if json.parse(body.get_string_from_utf8()) == OK:
                var res = json.get_data()
                _populate_models_list(res)
            else:
                status_lbl.text = "❌ Грешка при обработка на отговора."
                status_lbl.modulate = Color(1, 0.3, 0.3)
        else:
            status_lbl.text = "❌ Грешен или неактивен ключ! (Код " + str(response_code) + ")"
            status_lbl.modulate = Color(1, 0.3, 0.3)
    else:
        if response_code == 200:
            var json = JSON.new()
            if json.parse(body.get_string_from_utf8()) == OK:
                var res = json.get_data()
                var content = res["choices"][0]["message"]["content"].strip_edges()
                _add_log("[color=#00f2fe]" + current_model + ":[/color] " + content)
                _build(content.to_lower(), Vector3.INF)
        else:
            _add_log("[color=#ff4444]AI грешка (" + str(response_code) + "). Провери ключа от '⚙️ AI Облак'.[/color]")

func _populate_models_list(data: Dictionary):
    model_select.clear()
    fetched_models.clear()
    
    var list = data.get("data", [])
    if list.is_empty():
        list = data.get("models", [])

    for item in list:
        var m_id = ""
        if item is Dictionary:
            m_id = item.get("id", "")
        elif item is String:
            m_id = item
            
        if not m_id.is_empty():
            fetched_models.append(m_id)
            model_select.add_item(m_id)

    if fetched_models.size() > 0:
        status_lbl.text = "✅ Ключът е валиден! Свалени " + str(fetched_models.size()) + " модела."
        status_lbl.modulate = Color(0.2, 1, 0.4)
        current_model = fetched_models[0]
        current_model_chip.text = "🤖 " + current_model
        _save_config()
    else:
        status_lbl.text = "⚠️ Ключът работи, но не бяха върнати модели."
        status_lbl.modulate = Color(1, 0.8, 0.2)

func _on_model_selected(idx: int):
    if idx >= 0 and idx < fetched_models.size():
        current_model = fetched_models[idx]
        current_model_chip.text = "🤖 " + current_model
        _save_config()

func _save_config():
    var cfg = {
        "provider": current_provider_idx,
        "api_key": key_input.text.strip_edges(),
        "model": current_model,
        "models": fetched_models
    }
    var f = FileAccess.open("user://api_config.json", FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(cfg))

func _load_saved_config():
    if FileAccess.file_exists("user://api_config.json"):
        var f = FileAccess.open("user://api_config.json", FileAccess.READ)
        var json = JSON.new()
        if json.parse(f.get_as_text()) == OK:
            var cfg = json.get_data()
            current_provider_idx = cfg.get("provider", 0)
            provider_select.selected = current_provider_idx
            api_key = cfg.get("api_key", "")
            key_input.text = api_key
            current_model = cfg.get("model", "default")
            current_model_chip.text = "🤖 " + current_model
            fetched_models = cfg.get("models", [])
            if not fetched_models.is_empty():
                model_select.clear()
                for m in fetched_models:
                    model_select.add_item(m)
                var saved_idx = fetched_models.find(current_model)
                if saved_idx != -1:
                    model_select.selected = saved_idx

func _add_log(msg: String):
    chat_log.append_text(msg + "\n")

func _on_send_chat():
    var t = chat_input.text.strip_edges()
    if t.is_empty():
        return
    chat_input.text = ""
    _add_log("[color=#00ff88]Ти:[/color] " + t)

    if not api_key.is_empty() and current_model != "default":
        _request_ai_chat(t)
    else:
        _build(t.to_lower(), Vector3.INF)

func _on_chip_pressed(txt: String):
    _add_log("[color=#00ff88]Ти:[/color] " + txt)
    _build(txt.to_lower(), Vector3.INF)

func _request_ai_chat(prompt: String):
    var url = providers[current_provider_idx]["chat"]
    var headers = [
        "Authorization: Bearer " + api_key,
        "Content-Type: application/json"
    ]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")

    var sys_prompt = "Ти си 3D генератор. Отговаряй САМО с една дума от следните: [дърво, кола, сграда, блок], която най-точно описва обекта."
    var body = JSON.stringify({
        "model": current_model,
        "messages": [
            {"role": "system", "content": sys_prompt},
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 10,
        "temperature": 0.1
    })
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _build(prompt: String, forced_pos: Vector3 = Vector3.INF):
    var pos = forced_pos
    if pos == Vector3.INF:
        var fwd = -camera.global_transform.basis.z
        fwd.y = 0.0
        pos = camera.global_position + fwd.normalized() * 5.0
        pos.y = 0.0

    var obj = Node3D.new()
    obj.position = pos
    
    var rb = StaticBody3D.new()
    rb.add_to_group("prop")
    obj.add_child(rb)

    if "дърво" in prompt:
        obj.name = "Tree"
        var trunk = CylinderMesh.new()
        trunk.top_radius = 0.3
        trunk.bottom_radius = 0.4
        trunk.height = 1.8
        _add_mesh(rb, trunk, Vector3(0, 0.9, 0), Color(0.45, 0.25, 0.12))
        
        var leaves = SphereMesh.new()
        leaves.radius = 1.6
        leaves.height = 3.2
        _add_mesh(rb, leaves, Vector3(0, 2.8, 0), Color(0.12, 0.78, 0.22))
        
        var box_shape = BoxShape3D.new()
        box_shape.size = Vector3(2.5, 4.5, 2.5)
        _add_col(rb, box_shape, Vector3(0, 2.2, 0))

    elif "кола" in prompt:
        obj.name = "Car"
        var chassis = BoxMesh.new()
        chassis.size = Vector3(2.4, 0.8, 4.6)
        _add_mesh(rb, chassis, Vector3(0, 0.4, 0), Color(1.0, 0.1, 0.15))
        
        var cabin = BoxMesh.new()
        cabin.size = Vector3(1.8, 0.6, 2.2)
        _add_mesh(rb, cabin, Vector3(0, 1.1, -0.2), Color(0.12, 0.14, 0.18))
        
        var col_shape = BoxShape3D.new()
        col_shape.size = Vector3(2.4, 1.4, 4.6)
        _add_col(rb, col_shape, Vector3(0, 0.7, 0))

    else:
        obj.name = "Building"
        var building = BoxMesh.new()
        building.size = Vector3(3.0, 6.0, 3.0)
        _add_mesh(rb, building, Vector3(0, 3.0, 0), Color(0.22, 0.38, 0.58))
        
        var col_shape = BoxShape3D.new()
        col_shape.size = Vector3(3.0, 6.0, 3.0)
        _add_col(rb, col_shape, Vector3(0, 3.0, 0))

    world.add_child(obj)
    _select(obj)

func _add_mesh(parent_node: Node3D, mesh_res: Mesh, pos: Vector3, col: Color):
    var m = MeshInstance3D.new()
    m.mesh = mesh_res
    m.position = pos
    var mat = StandardMaterial3D.new()
    mat.albedo_color = col
    mat.roughness = 0.3
    m.material_override = mat
    parent_node.add_child(m)

func _add_col(parent_node: Node3D, shape_res: Shape3D, pos: Vector3):
    var c = CollisionShape3D.new()
    c.shape = shape_res
    c.position = pos
    parent_node.add_child(c)
