extends Node3D

@onready var world_spawn: Node3D = $WorldSpawn
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sun_light: DirectionalLight3D = $DirectionalLight3D
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var chat_ui: Control = $UI/Drawer
@onready var log_box: RichTextLabel = $UI/Drawer/Log
@onready var prompt_input: LineEdit = $UI/Drawer/PromptInput
@onready var key_input: LineEdit = $UI/SettingsModal/KeyInput
@onready var settings_modal: Panel = $UI/SettingsModal

var api_key: String = ""

func _ready():
http_request.request_completed.connect(_on_ai_response)
_log("[color=#00f2fe]Универсалният 3D енджин е активен![/color]\n• Разгледай с докосване (ляво = ход, дясно = поглед).\n• Избери шаблон или пиши свободен текст.")
_preset_cyberpunk()

func _on_toggle_drawer_pressed():
chat_ui.visible = !chat_ui.visible

func _on_settings_pressed():
settings_modal.visible = !settings_modal.visible

func _on_save_key_pressed():
api_key = key_input.text.strip_edges()
settings_modal.visible = false
_log("[color=#00ff88]API ключът е запазен![/color]")

func _preset_cyberpunk():
var recipe = {
"environment": { "sky_top": "#050814", "sky_horizon": "#1a0b2e", "sun_color": "#ff007f", "sun_energy": 1.2, "sun_rot": [-30, 45] },
"terrain": { "type": "flat", "size": 160.0, "color": "#0d0f17" },
"entities": [
{ "type": "building", "pos": [-15, 0, -20], "floors": 12, "width": 8.0, "color": "#111625", "neon": "#00f2fe" },
{ "type": "building", "pos": [15, 0, -25], "floors": 16, "width": 9.0, "color": "#181226", "neon": "#ff0055" },
{ "type": "building", "pos": [0, 0, -45], "floors": 20, "width": 12.0, "color": "#0d131f", "neon": "#ffe600" },
{ "type": "vehicle", "pos": [0, 0.2, -6], "rot": [0, 25, 0], "color": "#00f2fe" },
{ "type": "light", "pos": [0, 8, -6], "color": "#00f2fe", "energy": 5.0, "range": 22.0 }
]
}
WorldBuilder.build_world(recipe, world_spawn, world_env, sun_light)
_log("[color=#00ff88]Зареден свят: Киберпънк Метрополис[/color]")

func _preset_nature():
var recipe = {
"environment": { "sky_top": "#1976d2", "sky_horizon": "#90caf9", "sun_color": "#fffde7", "sun_energy": 2.0, "sun_rot": [-55, 20] },
"terrain": { "type": "islands", "size": 140.0, "height": 18.0, "color": "#2e7d32" },
"entities": []
}
for i in range(16):
var rx = randf_range(-30, 30)
var rz = randf_range(-30, 30)
recipe["entities"].append({ "type": "tree", "pos": [rx, 0, rz], "height": randf_range(4.0, 7.5), "leaf_color": "#1b5e20" })
WorldBuilder.build_world(recipe, world_spawn, world_env, sun_light)
_log("[color=#00ff88]Зареден свят: Планински Остров[/color]")

func _on_send_prompt():
var text = prompt_input.text.strip_edges()
if text.is_empty(): return
prompt_input.text = ""

if api_key.is_empty():
_log("[color=#ff3344]Въведи API ключ от ⚙️ за генериране с AI![/color]")
return

_log("[color=#ffff66]Ти:[/color] " + text)
_request_ai(text)

func _request_ai(prompt: String):
var headers = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
var sys = """Ти си универсален генератор на 3D светове за Godot 4.
{
  "environment": { "sky_top": "#HEX", "sky_horizon": "#HEX", "sun_color": "#HEX", "sun_energy": 1.5, "sun_rot": [-45, 30] },
  "terrain": { "type": "flat"|"mountains"|"islands"|"dunes", "size": 120.0, "height": 15.0, "color": "#HEX" },
  "entities": [
    { "type": "building"|"vehicle"|"tree"|"light"|"prop", "pos": [x,y,z], "scale": [1,1,1], "rot": [0,0,0], "color": "#HEX", "floors": 8, "width": 6.0, "neon": "#HEX" }
  ]
}"""
var body = JSON.stringify({
"model": "gpt-4o-mini",
"messages": [{"role": "system", "content": sys}, {"role": "user", "content": prompt}],
"temperature": 0.4
})
http_request.request("https://api.openai.com/v1/chat/completions", headers, HTTPClient.METHOD_POST, body)

func _on_ai_response(res, code, headers, body: PackedByteArray):
if code != 200:
_log("[color=#ff3344]Грешка при заявката: " + str(code) + "[/color]")
return
var json = JSON.new()
if json.parse(body.get_string_from_utf8()) == OK:
var raw = json.get_data()["choices"][0]["message"]["content"].strip_edges()
if raw.begins_with("```"):
raw = raw.trim_prefix("```json").trim_prefix("```").trim_suffix("```").strip_edges()
var parser = JSON.new()
if parser.parse(raw) == OK and parser.get_data() is Dictionary:
WorldBuilder.build_world(parser.get_data(), world_spawn, world_env, sun_light)
_log("[color=#00ff88]✓ Новият свят беше изчислен и нарисуван от GPU![/color]")
else:
_log("[color=#ff9900]Невалидна структура от AI.[/color]")

func _log(msg: String):
log_box.append_text(msg + "\n")
