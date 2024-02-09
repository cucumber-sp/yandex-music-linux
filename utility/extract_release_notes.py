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
                html += "<br/>"
            else:
                html += f"<span>{element['value']}</span>".replace('\n', '<br/>')
        elif element['type'] == 8:
            html += f"<{element['value']}>{build_html(element['children'])}</{element['value']}>"
    return html

with open(file_name, "r", encoding='utf-8') as file:
    full_text = file.read()

notes = {}
position = full_text.find("desktop-release-notes.")
while position != -1:
    start_position = position
    while full_text[position] != '"':
        position += 1
    name = full_text[start_position:position]
    position += 2
    start_position = position
    braces_count = 1
    while braces_count > 0:
        position += 1
        if full_text[position] == '{' or full_text[position] == '[':
            braces_count += 1
        elif full_text[position] == '}' or full_text[position] == ']':
            braces_count -= 1
    data = full_text[start_position:position + 1]
    notes[name] = build_html(json.loads(data), True)
    position = full_text.find("desktop-release-notes.", position)

with open(save_file_name, "w", encoding='utf-8') as file:
    file.write(json.dumps(notes, ensure_ascii=False, indent=4))