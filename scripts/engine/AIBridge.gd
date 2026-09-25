extends RefCounted

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

# Разпознаване на корените на думите (хваща "каща", "стена от тухли", "бемве")
static func detect_archetype(low: String) -> String:
if "стен" in low or "тухл" in low or "зид" in low or "оград" in low:
return "wall"
elif "пиан" in low or "роял" in low or "клавиш" in low:
return "piano"
elif "замък" in low or "замк" in low or "крепос" in low or "цитадел" in low:
return "castle"
elif "къщ" in low or "кащ" in low or "дом" in low or "вил" in low:
return "house"
elif "кол" in low or "бемв" in low or "bmw" in low or "кабри" in low:
return "car"
return ""

# Авто-коректор на счупен JSON
static func repair_json(raw: String) -> Dictionary:
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

var open_c = 0; var open_s = 0
for idx in range(s.length()):
var c = s[idx]
if c == '{': open_c += 1
elif c == '}': open_c -= 1
elif c == '[': open_s += 1
elif c == ']': open_s -= 1

var rep = s
var last_c = rep.rfind(",")
var last_b = max(rep.rfind("}"), rep.rfind("]"))
if last_c > last_b: rep = rep.substr(0, last_c)

while open_s > 0: rep += "]"; open_s -= 1
while open_c > 0: rep += "}"; open_c -= 1

if j.parse(rep) == OK and j.get_data() is Dictionary:
return j.get_data()

return {}
