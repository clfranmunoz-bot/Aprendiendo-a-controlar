import os
from PIL import Image, ImageDraw, ImageFilter

CLEANED_IMG = r"c:\Users\clmun\AndroidStudioProjects\aprender\app\src\main\res\drawable\ic_app_logo_cleaned.png"
RES_DIR = r"c:\Users\clmun\AndroidStudioProjects\aprender\app\src\main\res"

def prepare_icons_v2():
    if not os.path.exists(CLEANED_IMG):
        print(f"Error: Cleaned image not found at {CLEANED_IMG}")
        return
        
    img = Image.open(CLEANED_IMG).convert("RGBA")
    print(f"Loaded cleaned hammer: {img.size} {img.mode}")

    # Color tokens
    # azulClaro = RGB(231, 240, 250) -> Hex #E7F0FA
    bg_color = (231, 240, 250, 255)
    
    # Mipmap configurations (folder name to pixel size)
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192
    }

    # Generate mipmap icons
    for folder, size in sizes.items():
        folder_path = os.path.join(RES_DIR, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # --- 1. Standard Legacy Icon (Square with rounded corners) ---
        legacy_icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(legacy_icon)
        
        # Draw a beautiful rounded rectangle background
        r = size // 6  # corner radius
        draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=bg_color)
        
        # Resize and paste the hammer in the center (scale to 70% of icon size)
        hammer_size = int(size * 0.70)
        hammer_resized = resize_aspect(img, hammer_size)
        
        # Paste hammer in the center
        x = (size - hammer_resized.width) // 2
        y = (size - hammer_resized.height) // 2
        legacy_icon.alpha_composite(hammer_resized, (x, y))
        
        # Save as ic_launcher.webp
        webp_path = os.path.join(folder_path, "ic_launcher.webp")
        legacy_icon.save(webp_path, "WEBP", quality=100)
        print(f"Saved legacy icon: {webp_path}")

        # --- 2. Circular Legacy Icon ---
        round_icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw_round = ImageDraw.Draw(round_icon)
        
        # Draw a circular background
        draw_round.ellipse([0, 0, size - 1, size - 1], fill=bg_color)
        
        # Paste hammer in the center
        round_icon.alpha_composite(hammer_resized, (x, y))
        
        # Save as ic_launcher_round.webp
        round_webp_path = os.path.join(folder_path, "ic_launcher_round.webp")
        round_icon.save(round_webp_path, "WEBP", quality=100)
        print(f"Saved circular icon: {round_webp_path}")

    # --- 3. HIGH-RESOLUTION Adaptive Foreground for Android 12+ Splash Screens ---
    # To prevent pixelation on high-density devices (like Samsung S23 Ultra),
    # the drawable PNG resource should be high-res (e.g., 512x512 pixels).
    fg_size = 512
    adaptive_fg = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))
    
    # Scale hammer to fit the 66% safe center zone of a 512px canvas (approx 330px)
    hammer_adaptive_size = int(fg_size * 0.65)
    hammer_fg = resize_aspect(img, hammer_adaptive_size)
    
    # Anti-alias the alpha edges slightly to make it look incredibly smooth/vector-like
    # We can do a slight smooth filter on the resized image
    hammer_fg = hammer_fg.filter(ImageFilter.SMOOTH)
    
    fg_x = (fg_size - hammer_fg.width) // 2
    fg_y = (fg_size - hammer_fg.height) // 2
    adaptive_fg.alpha_composite(hammer_fg, (fg_x, fg_y))
    
    # Save adaptive foreground to drawable as high-res PNG
    fg_png_path = os.path.join(RES_DIR, "drawable", "ic_launcher_foreground.png")
    adaptive_fg.save(fg_png_path, "PNG")
    print(f"Saved high-resolution adaptive foreground: {fg_png_path} ({fg_size}x{fg_size})")

def resize_aspect(img, max_size):
    # Maintain aspect ratio while fitting within max_size x max_size
    width, height = img.size
    aspect = width / height
    if width > height:
        new_w = max_size
        new_h = int(max_size / aspect)
    else:
        new_h = max_size
        new_w = int(max_size * aspect)
    return img.resize((new_w, new_h), Image.Resampling.LANCZOS)

if __name__ == "__main__":
    prepare_icons_v2()
