import json
import sys
import requests

if len(sys.argv) < 2:
    print("Usage: python extract_release_notes.py <save_file_name>")
    sys.exit(1)

save_file_name = sys.argv[1]


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


response = requests.get("https://music-desktop-application.s3.yandex.net/stable/release-notes/ru.json")
if not response.ok:
    print("Failed to download file")
    sys.exit(1)

notes = {}
element_key: str
for element_key in response.json().keys():
    if not element_key.startswith("desktop-release-notes."):
        continue
    notes[element_key] = build_html(response.json()[element_key], True)

with open(save_file_name, "w", encoding='utf-8') as file:
    file.write(json.dumps(notes, ensure_ascii=False, indent=4))

