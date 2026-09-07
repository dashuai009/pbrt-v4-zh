"""Reproduce the pinned original Jeri's default HDR display as a static PNG.

No translation, model calls, resizing, cropping, or exposure fitting.
The original EXR remains the authority. CPU float64 is not bit-identical to
GLSL mediump or every browser framebuffer; visual comparison remains required.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import OpenEXR
import numpy as np
import PIL
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument("source", type=Path)
parser.add_argument("destination", type=Path)
args = parser.parse_args()
if args.source.suffix.lower() != ".exr" or args.destination.suffix.lower() != ".png":
    parser.error("Expected an EXR source and PNG destination")
if args.source.resolve() == args.destination.resolve():
    parser.error("The original must not be overwritten")
channels = OpenEXR.File(str(args.source)).channels()
if "RGB" not in channels:
    raise ValueError("Only explicit RGB images are supported; no guessed channel conversion")
rgb = channels["RGB"].pixels.astype(np.float64)
if rgb.ndim != 3 or rgb.shape[2] != 3 or not np.isfinite(rgb).all():
    raise ValueError("Expected finite RGB data")
# jeri.js 3282–3289, 3318: Gamma22=0; gain=1, offset=0, gamma=1.
display = np.clip(np.maximum(rgb, 0) ** (1 / 2.2), 0, 1)
pixels = np.rint(display * 255).astype(np.uint8)
args.destination.parent.mkdir(parents=True, exist_ok=True)
Image.fromarray(pixels).save(args.destination)
print(json.dumps({
    "source": str(args.source), "destination": str(args.destination),
    "source_sha256": hashlib.sha256(args.source.read_bytes()).hexdigest(),
    "destination_sha256": hashlib.sha256(args.destination.read_bytes()).hexdigest(),
    "width": rgb.shape[1], "height": rgb.shape[0],
    "transform": "clip(max(RGB,0)^(1/2.2),0,1); round-to-nearest 8-bit; no resize/crop/flip",
    "versions": {"Python": sys.version.split()[0], "OpenEXR": OpenEXR.__version__, "numpy": np.__version__, "Pillow": PIL.__version__},
    "limitation": "CPU float64; not a claim of GLSL/framebuffer bit identity",
}, indent=2))
