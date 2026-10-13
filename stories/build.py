#!/usr/bin/env python3
"""Build a Twee 3 story into a single playable HTML file, using a SugarCube format.js.

Usage:
  python3 stories/build.py stories/the-size-up/the-size-up.twee path/to/sugarcube/format.js stories/the-size-up/index.html

A small stand-in for Tweego (https://www.motoslave.net/tweego/) so the story builds anywhere
Python runs. If you have Tweego installed, this does the same job:
  tweego -o stories/the-size-up/index.html stories/the-size-up/the-size-up.twee

Code: MIT license.
"""
import html
import json
import re
import sys

HEADER = re.compile(r"^::\s*(?P<name>[^\[\{]+?)\s*(?:\[(?P<tags>[^\]]*)\])?\s*(?:\{(?P<meta>.*)\})?\s*$")


def parse(text):
    passages, cur = [], None
    for line in text.splitlines():
        if line.startswith("::"):
            m = HEADER.match(line)
            if not m:
                raise SystemExit(f"Bad passage header: {line}")
            cur = {"name": m.group("name").strip(), "tags": (m.group("tags") or "").split(), "body": []}
            passages.append(cur)
        elif cur is not None:
            cur["body"].append(line)
    for p in passages:
        p["body"] = "\n".join(p["body"]).strip("\n")
    return passages


def build(twee_path, format_path, out_path):
    passages = parse(open(twee_path, encoding="utf-8").read())
    by_name = {p["name"]: p for p in passages}
    title = by_name.pop("StoryTitle")["body"].strip()
    data = json.loads(by_name.pop("StoryData")["body"])

    fmt_src = open(format_path, encoding="utf-8").read()
    fmt = json.loads(fmt_src[fmt_src.index("(") + 1: fmt_src.rindex(")")])
    if fmt["name"] != data.get("format"):
        raise SystemExit("Story format does not match StoryData")

    styles = "\n".join(p["body"] for p in passages if "stylesheet" in p["tags"])
    scripts = "\n".join(p["body"] for p in passages if "script" in p["tags"])
    story = [p for p in passages if p["name"] in by_name and not {"stylesheet", "script"} & set(p["tags"])]
    names = [p["name"] for p in story]
    if data["start"] not in names:
        raise SystemExit(f"Start passage {data['start']!r} not found")

    rows = []
    for i, p in enumerate(story, start=1):
        if p["name"] == data["start"]:
            start_pid = i
        rows.append(
            f'<tw-passagedata pid="{i}" name="{html.escape(p["name"], quote=True)}" '
            f'tags="{html.escape(" ".join(p["tags"]), quote=True)}" position="{100 * i},100" size="100,100">'
            f'{html.escape(p["body"], quote=False)}</tw-passagedata>'
        )

    storydata = (
        f'<tw-storydata name="{html.escape(title, quote=True)}" startnode="{start_pid}" creator="mss build.py" '
        f'creator-version="1.0" ifid="{data["ifid"]}" zoom="1" format="{fmt["name"]}" '
        f'format-version="{fmt["version"]}" options="" hidden>'
        f'<style role="stylesheet" id="twine-user-stylesheet" type="text/twine-css">{styles}</style>'
        f'<script role="script" id="twine-user-script" type="text/twine-javascript">{scripts}</script>'
        + "".join(rows)
        + "</tw-storydata>"
    )

    out = fmt["source"].replace("{{STORY_NAME}}", html.escape(title)).replace("{{STORY_DATA}}", storydata)
    open(out_path, "w", encoding="utf-8").write(out)
    print(f"Built {out_path}: {len(story)} passages, SugarCube {fmt['version']}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(__doc__)
    build(*sys.argv[1:])
