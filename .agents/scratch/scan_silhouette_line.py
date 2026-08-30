from PIL import Image

def scan_line():
    img1_path = r"C:\Users\clmun\.gemini\antigravity\brain\c79c893e-3cef-4f40-9cf5-be2ad8b8de63\media__1778992087708.png"
    img = Image.open(img1_path).convert("RGBA")
    w, h = img.size
    mid_y = h // 2
    
    print(f"Scanning horizontal line at y={mid_y}:")
    # Let's print every 10th pixel across the middle line
    for x in range(0, w, 10):
        r, g, b, a = img.getpixel((x, mid_y))
        print(f"x={x}: ({r},{g},{b},{a})")

if __name__ == "__main__":
    scan_line()
