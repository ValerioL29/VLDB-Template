#!/usr/bin/env python3
"""Stage the Typst Universe package and test it the way a user gets it.

    python3 package.py [STAGE]      # default: build/

Renders thumbnail.png, copies the package to STAGE/preview/{name}/{version}/
with the template importing `@preview/{name}:{version}`, then runs
`typst init` from the staged copy and compiles the new project with and
without fonts/. To publish, copy that folder to
packages/preview/{name}/{version}/ in a fork of github.com/typst/packages.
"""

import shutil
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent
# Universe forbids fonts in packages, and check.py needs ../latex, so both stay
# in this repository only.
FILES = ["typst.toml", "LICENSE", "README.md", "pvldb.typ", "acm.csl", "thumbnail.png"]
TEMPLATE = ["main.typ", "refs.bib", "figures/duck.jpg"]
LOCAL_IMPORT = '#import "pvldb.typ"'


def run(*args):
    r = subprocess.run([str(a) for a in args], capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"FAIL: {' '.join(map(str, args))}\n{r.stderr}")
    return r


def copy(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def main():
    pkg = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
    spec = f"@preview/{pkg['name']}:{pkg['version']}"
    stage = Path(sys.argv[1] if len(sys.argv) > 1 else ROOT / "build").resolve()
    out = stage / "preview" / pkg["name"] / pkg["version"]
    assert spec in (ROOT / "README.md").read_text(), f"README.md does not mention {spec}"

    # Universe: page 1 as initialized, long edge >= 1080 px, at most 3 MiB.
    thumb = ROOT / "thumbnail.png"
    run("typst", "compile", "--font-path", ROOT / "fonts", "-f", "png", "--pages", "1", "--ppi", "250", ROOT / "main.typ", thumb)
    data = thumb.read_bytes()
    w, h = int.from_bytes(data[16:20], "big"), int.from_bytes(data[20:24], "big")
    assert max(w, h) >= 1080 and len(data) <= 3 * 2**20, (w, h, len(data))

    shutil.rmtree(out, ignore_errors=True)
    for f in FILES:
        copy(ROOT / f, out / f)
    for f in TEMPLATE:
        copy(ROOT / f, out / "template" / f)
    main_typ = out / "template" / "main.typ"
    text = main_typ.read_text()
    assert text.startswith(LOCAL_IMPORT), "main.typ must start with " + LOCAL_IMPORT
    main_typ.write_text(text.replace(LOCAL_IMPORT, f'#import "{spec}"', 1))

    with tempfile.TemporaryDirectory() as tmp:
        proj = Path(tmp) / "paper"
        run("typst", "init", "--package-path", stage, spec, proj)
        r = run("typst", "compile", "--package-path", stage, "--font-path", ROOT / "fonts", proj / "main.typ")
        if r.stderr.strip():
            sys.exit(f"FAIL: warnings with fonts/\n{r.stderr}")
        run("typst", "compile", "--package-path", stage, proj / "main.typ")  # fallback fonts: warns, must compile
    print(f"staged {spec} in {out}")
    print(f"thumbnail {w}x{h}, {len(data) / 2**20:.1f} MiB; typst init + compile ok")


if __name__ == "__main__":
    main()
