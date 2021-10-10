import sys
import math
from PIL import Image

# with Image.open('/Users/adomass/Documents/Projects/haxe/res/player/walk.png') as im:
#   im.show()

def getPreNumber(number):
  if number <= 9:
    return '000'
  if number <= 99:
    return '00'
  if number <= 999:
    return '0'
  return ''

dest = "/Users/adomass/Documents/Projects/haxe/res/player/"

def main(args):
  if (len(args) < 5):
    raise("MISSING ARGS")
  spriteSize = 256
  path = args[1]
  start = int(args[2])
  end = int(args[3])
  cols = int(args[4])
  name = args[5]
  imageCount = end - start + 1
  
  print(imageCount)
  rows = math.ceil(imageCount / cols)
  spriteSheet = Image.new('RGBA', (spriteSize * cols, spriteSize * rows), (0,0,0,0))
  
  for i in range(0, imageCount):
    currentImageNumber = start + i
    image = Image.open(path + '/' + getPreNumber(currentImageNumber) + str(currentImageNumber) + '.png')
    row = math.floor(i / cols)
    col = i % cols
    spriteSheet.paste(image, (col * spriteSize, row * spriteSize))
  spriteSheet.show()
  if name:
    spriteSheet.save(dest+ name + '.png',"png")
  else:
    spriteSheet.save(dest + "spritesheet.png","png")

  print(spriteSheet)

if __name__ == "__main__":
  print("Args: 1. Path to images; 2. Start; 3. End; 4. Colums per row; 5. Name")
  main(sys.argv)


