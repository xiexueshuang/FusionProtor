from PIL import Image
import rembg
import cv2
import numpy as np

SUCCESS = 0
BUSINESS_FAIL = 1


class ResponseWrapper:
    @staticmethod
    def success(data=None):
        return {
            'success': True,
            'data': data,
            'code': SUCCESS,
            'message': ''
        }

    @staticmethod
    def fail(code, message):
        return {
            'success': False,
            'data': None,
            'code': code,
            'message': message
        }


class BusinessException(Exception):
    def __init__(self, code=BUSINESS_FAIL, message=''):
        self.code = code
        self.message = message
        super().__init__(self.message)


class Img2Img:
    def __init__(self, url, imageId, styleId):
        self.url = url
        self.imageId = imageId
        self.styleId = styleId
        
    def to_dict(self):
        # 返回字典格式，便于转换为 JSON
        return {
            "imageId": self.imageId,
            "url": self.url,
            "styleId": self.styleId
        }

def process_image(input_image_path):
    output_image_path = input_image_path
    # Step 1: Remove background
    input_image = Image.open(input_image_path)
    output_image = rembg.remove(input_image)
    # output_image = output_image.convert("RGB")
    
    # background_image = Image.new("RGBA", output_image.size, (255, 255, 255, 255))
    # background_image.paste(output_image, (0, 0), output_image)

    # Step 2: Convert the output to RGB (just in case it's RGBA)
    bbox = output_image.getbbox()
    # print(bbox)
    cropped_image = output_image.crop(bbox)
    background_image = Image.new("RGBA", cropped_image.size, (255, 255, 255, 255))
    background_image.paste(cropped_image, (0, 0), cropped_image)
    output_image = background_image.convert("RGB")

    # Step 5: Create a new white background 1024x1024 image
    result_image = Image.new("RGB", (1920, 1080), (255, 255, 255))

    # Step 6: Calculate the position to paste the cropped image onto the 1024x1024 background
    width, height = output_image.size
    paste_position = ((1920 - width) // 2, (1080 - height) // 2)

    # Step 7: Paste the cropped image onto the 1024x1024 background
    result_image.paste(output_image, paste_position)

    # Step 8: Save the result image
    result_image.save(output_image_path)

if __name__ == "__main__":
    input_image_path = "/data0/xxl/ProtoFusion/car2.png"  # 输入图片路径
    # output_image_path = "/data0/xxl/ProtoFusion/source_image/exampleId_吸尘器.png"  # 输出图片路径

    process_image(input_image_path)