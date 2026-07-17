from PIL import Image
import sys

img = Image.open('/Users/krem/.gemini/antigravity-ide/brain/b973ca1f-44ec-416b-bbeb-ed9b6cfbb2a9/media__1783937662284.jpg').convert('L')
w, h = img.size

# Let's see where the brightest pixels (white radio buttons or text) are
left_bright = 0
right_bright = 0
for x in range(w):
    for y in range(h):
        if img.getpixel((x, y)) > 200: # bright pixel
            if x < w/2:
                left_bright += 1
            else:
                right_bright += 1

print(f"Bright pixels on Left: {left_bright}")
print(f"Bright pixels on Right: {right_bright}")
