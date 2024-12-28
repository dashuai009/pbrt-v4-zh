import numpy as np
import cv2
im=cv2.imread("../pbr-book-website/4ed/Introduction/watercolor-path.exr",-1)
im=im*65535
im[im>65535]=65535
im=np.uint16(im)
cv2.imwrite("torus.png",im)


exit(0)


import OpenEXR
import Imath
from PIL import Image
import numpy as np

# 读取EXR文件
def read_exr(file_path):
    exr_file = OpenEXR.InputFile(file_path)
    dw = exr_file.header()['dataWindow']
    size = (dw.max.x - dw.min.x + 1, dw.max.y - dw.min.y + 1)

    # 读取RGB三个通道的数据
    pt = Imath.PixelType(Imath.PixelType.FLOAT)
    redstr = exr_file.channel('R', pt)
    greenstr = exr_file.channel('G', pt)
    bluestr = exr_file.channel('B', pt)

    # 将字符串数据转换为numpy数组
    red = np.frombuffer(redstr, dtype=np.float32)
    green = np.frombuffer(greenstr, dtype=np.float32)
    blue = np.frombuffer(bluestr, dtype=np.float32)

    red.shape = green.shape = blue.shape = (size[1], size[0])
    return red, green, blue

# 将numpy数组转换为图像
def exr_to_png(exr_path, png_path):
    r, g, b = read_exr(exr_path)
    img = np.stack([r, g, b], axis=-1)

    # 归一化到0-255
    norm_img = ((img - img.min()) / (img.max() - img.min()) * 255).astype(np.uint8)
    image = Image.fromarray(norm_img, 'RGB')
    image.save(png_path, format='PNG')

# 转换文件
exr_to_png('../pbr-book-website/4ed/Introduction/watercolor-path.exr', 'output.png')
