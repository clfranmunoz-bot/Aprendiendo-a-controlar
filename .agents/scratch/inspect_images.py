import os
from PIL import Image

img1_path = r"C:\Users\clmun\.gemini\antigravity\brain\c79c893e-3cef-4f40-9cf5-be2ad8b8de63\media__1778992087708.png"
img2_path = r"C:\Users\clmun\.gemini\antigravity\brain\c79c893e-3cef-4f40-9cf5-be2ad8b8de63\media__1778992435812.png"

def inspect():
    for name, path in [("img1", img1_path), ("img2", img2_path)]:
        if os.path.exists(path):
            img = Image.open(path)
            print(f"{name}: path={path}")
            print(f"  size={img.size}, mode={img.mode}")
            # Check corners to see if they are transparent or have checkerboard colors
            pixels = img.convert("RGBA")
            corners = [pixels.getpixel((0,0)), pixels.getpixel((img.size[0]-1, 0)), 
                       pixels.getpixel((0, img.size[1]-1)), pixels.getpixel((img.size[0]-1, img.size[1]-1))]
            print(f"  corners (RGBA): {corners}")

if __name__ == "__main__":
    inspect()
