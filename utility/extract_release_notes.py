import sys
import json

if len(sys.argv) < 3:
    print("Usage: python extract_release_notes.py <file_name>")
    sys.exit(1)

file_name = sys.argv[1]
save_file_name = sys.argv[2]
    
def build_html(data, first_launch=False):
    html = ""
    for i, element in enumerate(data):
        if element['type'] == 0:
            if first_launch and i == 0:
                html += f"<h3>{element['value']}</h3>".replace('\n', '<br/>')
                continue
            if element['value'] == '\n':
                continue
            else:
                html += f"<span>{element['value']}</span>".replace('\n', '<br/>')
        elif element['type'] == 8:
            html += f"<{element['value']}>{build_html(element['children'])}</{element['value']}>"
    return html

with open(file_name, "r", encoding='utf-8') as file:
    translation = json.load(file)

notes = {}
element_key: str
for element_key in translation.keys():
    if not element_key.startswith("desktop-release-notes."):
        continue
    notes[element_key] = build_html(translation[element_key], True)

with open(save_file_name, "w", encoding='utf-8') as file:
    file.write(json.dumps(notes, ensure_ascii=False, indent=4))