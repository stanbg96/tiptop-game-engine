extends Node

func get_prompt() -> String:
return """You are a 3D Procedural CAD Engine. Output ONLY valid JSON:
{"name":"Name", "parts":[{"shape":"box"|"sphere"|"cylinder"|"prism"|"torus", "pos":[x,y,z], "size":[w,h,d], "rot":[x,y,z], "color":"#HEX", "metallic":0.0-1.0, "roughness":0.0-1.0, "clearcoat":0.0-1.0}]}
Y=0 is ground."""

func detect_archetype(txt: String) -> String:
var low = txt.to_lower()
if "пиан" in low or "роял" in low: return "piano"
if "замък" in low or "крепос" in low: return "castle"
if "стен" in low or "тухл" in low: return "wall"
if "къщ" in low or "кащ" in low or "дом" in low: return "house"
if "кол" in low or "бемв" in low or "bmw" in low: return "car"
return ""

func clean_json(raw: String) -> Dictionary:
var s = raw.strip_edges()
var s_idx = s.find("{"); var e_idx = s.rfind("}")
if s_idx != -1 and e_idx != -1: s = s.substr(s_idx, e_idx - s_idx + 1)
var j = JSON.new()
if j.parse(s) == OK and j.get_data() is Dictionary: return j.get_data()
return {}
