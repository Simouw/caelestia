import os
import sys

cache = os.path.expanduser('~/.cache/wallpaper-thumbs')
bg = os.path.expanduser('~/Pictures/bgs')

if os.path.exists(bg):
    for f in sorted(os.listdir(bg)):
        p = os.path.join(bg, f)
        if os.path.isfile(p) and f.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
            t = os.path.join(cache, os.path.splitext(f)[0] + '.png')
            sys.stdout.buffer.write(f.encode('utf-8') + b'\x00icon\x1f' + t.encode('utf-8') + b'\n')
sys.stdout.flush()
