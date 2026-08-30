from PIL import Image

def scan_line2():
    img2_path = r"C:\Users\clmun\.gemini\antigravity\brain\c79c893e-3cef-4f40-9cf5-be2ad8b8de63\media__1778992435812.png"
    img = Image.open(img2_path).convert("RGBA")
    w, h = img.size
    mid_y = h // 2
    
    print(f"Scanning horizontal line in img2 at y={mid_y}:")
    for x in range(0, w, 20):
        r, g, b, a = img.getpixel((x, mid_y))
        print(f"x={x}: ({r},{g},{b},{a})")

if __name__ == "__main__":
    scan_line2()
