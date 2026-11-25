"""Import new illustrations into the app.

Put 1024 px (or larger) PNGs, named exactly as in IMAGE_PROMPTS.md, in:
  D:\\jmk\\niraaha\\new_art\\light\\        -> assets/images/ (+ 2.0x, 3.0x)        replaces the light picture
  D:\\jmk\\niraaha\\new_art\\dark\\         -> assets/images/dark/ (+ 2.0x, 3.0x)   shown in dark mode
  D:\\jmk\\niraaha\\new_art\\options_dark\\ -> assets/images/options_dark/ (512 px)
Then from the app folder:  python tool/import_art.py
"""
import os, sys
from PIL import Image

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = sys.argv[1] if len(sys.argv) > 1 else os.path.join(APP, "..", "..", "..", "new-assets", "new_art")
IMG = os.path.join(APP, "assets", "images")


def base_width(name: str) -> int:
    p = os.path.join(IMG, name)
    w = Image.open(p).size[0] if os.path.exists(p) else 320
    return max(w, 320)  # the old screen* pictures were 41-180 px wide, which is why they looked blurred


def save(im: Image.Image, path: str, width: int) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    h = round(im.size[1] * width / im.size[0])
    # Written to a temporary file first, so a run that is stopped half way never leaves a broken picture behind.
    im.resize((width, h), Image.LANCZOS).save(path + ".tmp", "WEBP", quality=88, method=4)
    os.replace(path + ".tmp", path)


def main() -> None:
    done = 0
    for kind in ("light", "dark", "options_dark"):
        src = os.path.join(ART, kind)
        if not os.path.isdir(src):
            continue
        for f in sorted(os.listdir(src)):
            if not f.lower().endswith((".png", ".webp", ".jpg", ".jpeg")):
                continue
            name = os.path.splitext(f)[0] + ".webp"
            sp = os.path.join(src, f)
            last = os.path.join(IMG, "options_dark", name) if kind == "options_dark" else os.path.join(IMG if kind == "light" else os.path.join(IMG, "dark"), "3.0x", name)
            if os.path.exists(last) and os.path.getmtime(last) > os.path.getmtime(sp):
                continue  # already imported
            im = Image.open(os.path.join(src, f)).convert("RGBA")
            if im.size[0] < 900:
                print(f"! {kind}/{f}: only {im.size[0]} px wide; please give at least 1024 px")
            if kind == "options_dark":
                save(im, os.path.join(IMG, "options_dark", name), 512)
            else:
                root = IMG if kind == "light" else os.path.join(IMG, "dark")
                w = base_width(name)
                save(im, os.path.join(root, name), w)
                save(im, os.path.join(root, "2.0x", name), w * 2)
                save(im, os.path.join(root, "3.0x", name), w * 3)
            done += 1
            print(f"ok {kind}/{name}")
    print(f"{done} pictures imported. Run: flutter clean; flutter pub get; flutter build apk ...")


if __name__ == "__main__":
    sys.exit(main())
