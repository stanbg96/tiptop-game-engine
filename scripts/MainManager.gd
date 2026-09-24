extends Node3D

@onready var world_spawn: Node3D = $WorldSpawn
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var chat_ui: Control = $UI/Drawer
@onready var log_box: RichTextLabel = $UI/Drawer/Log
@onready var prompt_input: LineEdit = $UI/Drawer/PromptInput
@onready var key_input: LineEdit = $UI/SettingsModal/KeyInput
@onready var settings_modal: Panel = $UI/SettingsModal

var api_key: String = ""

func _ready():
http_request.request_completed.connect(_on_ai_response)
_log("[color=#00f2fe]Godot 4 3D Енджин зареден![/color]\n• Завърти с пръст екрана, за да огледаш модела.\n• Натисни '🏎️ Кола' или въведи команда.")
_spawn_default_car()

func _on_toggle_drawer_pressed():
chat_ui.visible = !chat_ui.visible

func _on_settings_pressed():
settings_modal.visible = !settings_modal.visible

func _on_save_key_pressed():
api_key = key_input.text.strip_edges()
settings_modal.visible = false
_log("[color=#00ff88]API ключът е запазен.[/color]")

func _spawn_default_car():
for c in world_spawn.get_children():
c.queue_free()
var recipe = {
"body": {
"length": 4.6,
"width": 2.0,
"height": 1.25,
"paint_color": "#ff0044"
}
}
var start = Time.get_ticks_usec()
var car = ProceduralCore.build_bezier_car(recipe)
world_spawn.add_child(car)
var ms = (Time.get_ticks_usec() - start) / 1000.0
_log("[color=#00ff88]✓ Генерирано в RAM за: " + str(ms) + " ms[/color]")

func _on_send_prompt():
var text = prompt_input.text.strip_edges()
if text.is_empty(): return
prompt_input.text = ""

if api_key.is_empty():
_log("[color=#ff3344]Въведи API ключ от ⚙️ за връзка с AI![/color]")
return

_log("[color=#ffff66]Ти:[/color] " + text)
_request_ai(text)

func _request_ai(prompt: String):
var headers = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
var sys = "Връщай САМО валиден JSON: {\"body\": {\"length\": 4.6, \"width\": 2.0, \"height\": 1.25, \"paint_color\": \"#HEX\"}}"
var body = JSON.stringify({
"model": "gpt-4o-mini",
"messages": [{"role": "system", "content": sys}, {"role": "user", "content": prompt}],
"temperature": 0.2
})
http_request.request("https://api.openai.com/v1/chat/completions", headers, HTTPClient.METHOD_POST, body)

func _on_ai_response(res, code, headers, body: PackedByteArray):
if code != 200:
_log("[color=#ff3344]Грешка при заявка: " + str(code) + "[/color]")
return
var json = JSON.new()
if json.parse(body.get_string_from_utf8()) == OK:
var raw = json.get_data()["choices"][0]["message"]["content"].strip_edges()
if raw.begins_with("```"):
raw = raw.trim_prefix("```json").trim_prefix("```").trim_suffix("```").strip_edges()
var p = JSON.new()
if p.parse(raw) == OK and p.get_data() is Dictionary:
for c in world_spawn.get_children():
c.queue_free()
var car = ProceduralCore.build_bezier_car(p.get_data())
world_spawn.add_child(car)
_log("[color=#00ff88]✓ AI моделът е построен в RAM![/color]")

func _log(msg: String):
log_box.append_text(msg + "\n")
