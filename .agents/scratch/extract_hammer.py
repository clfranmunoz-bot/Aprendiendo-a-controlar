import os
import numpy as np
from PIL import Image

def extract_hammer():
    img_path = r"C:\Users\clmun\.gemini\antigravity\brain\c79c893e-3cef-4f40-9cf5-be2ad8b8de63\media__1778992435812.png"
    img = Image.open(img_path).convert("RGBA")
    arr = np.array(img)
    h, w, c = arr.shape
    
    # Create output image (transparent background)
    output = np.zeros((h, w, 4), dtype=np.uint8)
    
    # The hammer is dark (R < 120, G < 120, B < 120)
    dark_mask = (arr[:, :, 0] < 120) & (arr[:, :, 1] < 120) & (arr[:, :, 2] < 120)
    
    # Let's find the bounding box of all dark pixels
    rows = np.any(dark_mask, axis=1)
    cols = np.any(dark_mask, axis=0)
    rmin, rmax = np.where(rows)[0][[0, -1]]
    cmin, cmax = np.where(cols)[0][[0, -1]]
    
    print(f"Hammer bounding box: y=[{rmin}, {rmax}], x=[{cmin}, {cmax}]")
    
    # Flood fill starting from all outer edges of the image to find the background
    background = np.zeros((h, w), dtype=bool)
    fillable = ~dark_mask
    
    queue = []
    # Top and bottom rows
    for x in range(w):
        if fillable[0, x]:
            queue.append((0, x))
            background[0, x] = True
        if fillable[h-1, x]:
            queue.append((h-1, x))
            background[h-1, x] = True
    # Left and right columns
    for y in range(1, h-1):
        if fillable[y, 0]:
            queue.append((y, 0))
            background[y, 0] = True
        if fillable[y, w-1]:
            queue.append((y, w-1))
            background[y, w-1] = True
            
    # Breadth-first search
    head = 0
    while head < len(queue):
        cy, cx = queue[head]
        head += 1
        
        # 4-connectivity neighbors
        for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w:
                if fillable[ny, nx] and not background[ny, nx]:
                    background[ny, nx] = True
                    queue.append((ny, nx))
                    
    # The hammer is everything that is NOT background!
    hammer_mask = ~background
    
    # Let's build the output image
    for y in range(h):
        for x in range(w):
            if hammer_mask[y, x]:
                output[y, x] = arr[y, x]
            else:
                output[y, x] = [0, 0, 0, 0]
                
    # Crop to bounding box with a margin
    margin = 10
    ymin = max(0, rmin - margin)
    ymax = min(h, rmax + margin)
    xmin = max(0, cmin - margin)
    xmax = min(w, cmax + margin)
    
    cropped_arr = output[ymin:ymax, xmin:xmax]
    cropped_img = Image.fromarray(cropped_arr)
    
    # Save the cleaned image!
    cleaned_path = r"c:\Users\clmun\AndroidStudioProjects\aprender\app\src\main\res\drawable\ic_app_logo_cleaned.png"
    cropped_img.save(cleaned_path, "PNG")
    print(f"Saved cleaned, cropped transparent hammer: {cleaned_path} (size={cropped_img.size})")

if __name__ == "__main__":
    extract_hammer()
