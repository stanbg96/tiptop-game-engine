class_name AIBridge

static func get_system_prompt() -> String:
return """You are an expert 3D Procedural CAD Modeler.
Understand user intent even with spelling typos (e.g. 'каща' -> house, 'тухлена стена' -> brick wall).
Output ONLY raw JSON (no markdown, no backticks, no explanations):
{
  "name": "BulgarianName",
  "parts": [
    {
      "shape": "box" | "sphere" | "cylinder" | "torus" | "prism",
      "pos": [x, y, z],
      "size": [w, h, d],
      "rot": [pitch_deg, yaw_deg, roll_deg],
      "color": "#HEX",
      "metallic": 0.0-1.0,
      "roughness": 0.0-1.0,
      "clearcoat": 0.0-1.0
    }
  ]
}
Y=0 is ground level (Y>=0). Use 6 to 18 detailed parts."""

# Толерантност към правописни грешки (Fuzzy Stemming)
static func detect_archetype(low: String) -> String:
if "стен" in low or "тухл" in low or "зид" in low or "оград" in low:
return "wall"
elif "пиан" in low or "роял" in low or "клавиш" in low:
return "piano"
elif "замък" in low or "замк" in low or "крепос" in low or "цитадел" in low:
return "castle"
elif "къщ" in low or "кащ" in low or "дом" in low or "вил" in low or "хиж" in low:
return "house"
elif "кол" in low or "бемв" in low or "bmw" in low or "кабри" in low or "автомоб" in low:
return "car"
return ""

# Авто-коректор на счупен или незатворен JSON
static func auto_repair_json(raw: String) -> Dictionary:
var s = raw.strip_edges()
if s.contains("```"):
var parts = s.split("```")
for p in parts:
var t = p.strip_edges()
if t.begins_with("json"): t = t.substr(4).strip_edges()
if t.contains("{"): s = t; break

var s_idx = s.find("{")
if s_idx == -1: return {}
s = s.substr(s_idx)

var reg = RegEx.new()
reg.compile(",\\s*([\\]\\}])")
s = reg.sub(s, "$1", true)

var j = JSON.new()
if j.parse(s) == OK and j.get_data() is Dictionary:
return j.get_data()

var open_curly = 0
var open_square = 0
for idx in range(s.length()):
var c = s[idx]
if c == '{': open_curly += 1
elif c == '}': open_curly -= 1
elif c == '[': open_square += 1
elif c == ']': open_square -= 1

var repaired = s
var last_comma = repaired.rfind(",")
var last_brace = max(repaired.rfind("}"), repaired.rfind("]"))
if last_comma > last_brace:
repaired = repaired.substr(0, last_comma)

while open_square > 0:
repaired += "]"
open_square -= 1
while open_curly > 0:
repaired += "}"
open_curly -= 1

if j.parse(repaired) == OK and j.get_data() is Dictionary:
return j.get_data()

return {}
