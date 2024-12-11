from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import gradio as gr
import uvicorn
import numpy as np
import json
import cv2
import os
from src.demo.model import DesignEdit
from src.utils.mask import remove_background_get_mask, mask_a_image, Images, ComponentImages
from src.demo.utils import segment_with_box
from typing import List, Tuple
from pydantic import BaseModel
import base64
from io import BytesIO

ENDPOINTS = "http://refinity-protofusion.pub.hsuni.top:29002"
# port = 29002

pretrained_model_path = "/data0/xxl/sdwebui/stable-diffusion-webui/models/Stable-diffusion/stable-diffusion-xl-base-1.0"
output_dir = "/data0/xxl/ProtoFusion/outputs/"
model =  DesignEdit(pretrained_model_path=pretrained_model_path)
# model.run_remove(original_image, mask_1, mask_2, mask_3, refine_mask=None, 
#         ori_1=None, ori_2=None, ori_3=None,
#         prompt="", save_dir="./tmp", mode='removal')

def extract_component(user_token, original_image, componentCount, boundingBox, imageId, object_mask):
    output = []
    save_dir = output_dir + imageId + "/"
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    if len(object_mask.shape) == 3:
        object_mask = cv2.cvtColor(object_mask, cv2.COLOR_BGR2GRAY)
    refine_mask = cv2.bitwise_not(object_mask)
    # extract_componentor = model.run_remove()
    mask_remain = object_mask
    for i in range(len(boundingBox)):
        # [[x / 2 for x in sublist] for sublist in boundingBox[i]]
        component = []
        # global_points = [[ x / 2 for x in sublist] for sublist in boundingBox[i]]
        global_points = boundingBox[i]
        print(global_points)
        tag = "component{}".format(i+1)
    
        # 逻辑1输出
        mask = segment_with_box(original_image, global_points)
        mask_remain = cv2.subtract(mask_remain, mask)
        _, mask_remain = cv2.threshold(mask_remain, 1, 255, cv2.THRESH_BINARY)
        image1 = mask_a_image(original_image, mask)
        image1_id = f"{user_token}_component{i+1}_1.png"      
        image1_dir = save_dir + image1_id
        cv2.imwrite(image1_dir, image1)
        # image1.save(image1_dir)
        url1 = f"{ENDPOINTS}/{imageId}/{image1_id}"
        image1_dict = Images(imageId=imageId + "/" + image1_id, url=url1, styleId=1).to_dict()
        component.append(image1_dict)
        
        # 逻辑2输出
        mask = cv2.subtract(object_mask, mask)
        _, mask = cv2.threshold(mask, 1, 255, cv2.THRESH_BINARY)
        image2 = model.run_remove(original_image=original_image, mask_1=mask, refine_mask=refine_mask)[0]
        # print(type(image2))
        image2_id = f"{user_token}_component{i+1}_2.png"
        image2_dir = save_dir + image2_id
        cv2.imwrite(image2_dir, image2)
        url2 = f"{ENDPOINTS}/{imageId}/{image2_id}"
        image2_dict = Images(imageId=imageId + "/" + image2_id, url=url2, styleId=1).to_dict()
        component.append(image2_dict)
        ComponentImagesinstance = ComponentImages(tag = tag, images = component)
        output.append(ComponentImagesinstance.to_dict())

    # 逻辑1输出
    component = []
    idx = len(boundingBox) + 1
    tag = "component{}".format(idx)
    mask = mask_remain
    image1 = mask_a_image(original_image, mask)
    image1_id = f"{user_token}_component{idx}_1.png"
    image1_dir = save_dir + image1_id
    cv2.imwrite(image1_dir, image1)
    url1 = f"{ENDPOINTS}/{imageId}/{image1_id}"
    image1_dict = Images(imageId=imageId + "/" + image1_id, url=url1, styleId=1).to_dict()
    component.append(image1_dict)
    # 逻辑2输出
    mask = cv2.subtract(object_mask, mask_remain)
    image2 = model.run_remove(original_image=original_image, mask_1=mask, refine_mask=refine_mask)[0]
    image2_id = f"{user_token}_component{idx}_2.png"
    image2_dir = save_dir + image2_id
    cv2.imwrite(image2_dir, image2)
    url2 = f"{ENDPOINTS}/{imageId}/{image2_id}"
    image2_dict = Images(imageId=imageId + "/" + image2_id, url=url2, styleId=1).to_dict()
    component.append(image2_dict)
    ComponentImagesinstance = ComponentImages(tag = tag, images = component)
    output.append(ComponentImagesinstance.to_dict())
    return output

# 创建 FastAPI 应用
app = FastAPI()

# # 创建 Gradio 模型的输入数据模型
# class GradioInput(BaseModel):
#     user_token: str
#     original_image: str  
#     componentCount: int  # 图像中识别出的组件数量
#     boundingBox: List[List[List[int]]]  # 组件的边界框，每个边界框是一个二维数组，表示多个顶点的坐标
#     imageId: str

class GradioInput(BaseModel):
    user_token: str
    original_image: str  # Base64编码的图像
    componentCount: int
    boundingBox: list  # 或者更详细的类型
    imageId: str

# POST 接口定义
@app.post("/predict/")
def predict(data: GradioInput):
    # try:
    # 解码Base64图像数据
    image_data = base64.b64decode(data.original_image)
    # 将字节数据转换为 NumPy 数组
    nparr = np.frombuffer(image_data, np.uint8)
    # 使用OpenCV从字节数组中读取图像
    original_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    # 检查图像是否读取成功
    if original_image is None:
        print("Failed to decode image")
    else:
        print("ok")  # 打印图像数据（NumPy数组）
    object_mask = remove_background_get_mask(original_image)
    componentImages = extract_component(
        data.user_token,
        original_image, 
        data.componentCount, 
        data.boundingBox,
        data.imageId,
        object_mask
    )
    # 返回输出数据
    return {"componentImages": componentImages}
    # except Exception as e:
    #     print(f"Error: {e}")
    #     raise HTTPException(status_code=500, detail=str(e))

# 启动 FastAPI 应用
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, debug=True)
