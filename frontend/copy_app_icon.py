import shutil
import os

project_root = r"d:\course antigravity\UCPApp"
icon_src = r"C:\Users\G.B\.gemini\antigravity\brain\2304b47a-3162-441f-900e-fef52eb923e1\ucp_app_icon_1779096890862.png"

assets_images_dir = os.path.join(project_root, "frontend", "assets", "images")
os.makedirs(assets_images_dir, exist_ok=True)

dest_icon_path = os.path.join(assets_images_dir, "app_icon.png")
shutil.copy2(icon_src, dest_icon_path)

print(f"Copied app icon to: {dest_icon_path}")
