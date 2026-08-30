import os
import numpy as np
from PIL import Image

def analyze_and_clean():
    img1_path = r"C:\Users\clmun\.gemini\antigravity\brain\c79c893e-3cef-4f40-9cf5-be2ad8b8de63\media__1778992087708.png"
    img2_path = r"C:\Users\clmun\.gemini\antigravity\brain\c79c893e-3cef-4f40-9cf5-be2ad8b8de63\media__1778992435812.png"
    
    # Let's inspect img1 first since it's vertical and probably a crop of just the hammer area
    img = Image.open(img1_path).convert("RGBA")
    arr = np.array(img)
    
    # Print the shape
    print(f"img1 shape: {arr.shape}")
    
    # Let's count how many pixels are close to black
    # The hammer is black, so let's find pixels where R, G, B are all very low (e.g. < 40)
    black_mask = (arr[:, :, 0] < 40) & (arr[:, :, 1] < 40) & (arr[:, :, 2] < 40)
    print(f"Pixels with R,G,B < 40: {np.sum(black_mask)}")
    
    # Let's also find pixels where it's a white highlight on the hammer (R,G,B are high, e.g. > 200)
    # The hammer has some white highlights.
    white_mask = (arr[:, :, 0] > 200) & (arr[:, :, 1] > 200) & (arr[:, :, 2] > 200)
    print(f"Pixels with R,G,B > 200: {np.sum(white_mask)}")

if __name__ == "__main__":
    analyze_and_clean()
