from ProtoFusionAPI import Comfyui_api, Tencentcloud_api, Rodin_api
import random
from gradio_client import Client
from flask import Flask, jsonify, request, send_from_directory
from utils import ResponseWrapper, BusinessException, BUSINESS_FAIL, Img2Img, process_image
import base64
from PIL import Image
import io
import json
import os
import requests
import time

source_image_dir = "/data0/xxl/ProtoFusion/source_image/"
style_image_dir = "/data0/xxl/ProtoFusion/style_image/"
output_dir = "/data0/xxl/ProtoFusion/outputs/"
workflowfile = "style+img.json"
ENDPOINTS = "http://refinity-protofusion.pub.hsuni.top:"
DesignEdit_ENDPOINTS = "http://localhost:8000/predict/"
Rodin_ENDPOINT = "https://hyperhuman.deemos.com/api/v2/rodin"
Rodin_API_KEY = "3pJffIkgVDa1SK9Ds7M7lQtwp9ZRajwYSR8u5RzHYfsY9gDUhhQcCsC88tGSuKtX"  # Replace with your actual API key
port = 29002


def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')


app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    return "OK"

@app.route('/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(output_dir, filename)


@app.route('/GenerateCandidateEntireImage', methods = ['POST'])
def GenerateCandidateEntireImage():
    try:
        # 处理用户token
        user_token = str(request.json.get('user_token'))

        # 处理Prompt和参数
        test_prompt = str(request.json.get('prompt'))
        denoising_strength = float(request.json.get("denoising_strength"))
        print(denoising_strength)
        # 处理图像
        base64_str = request.json.get('image')
        if base64_str.startswith('data:image'):
            base64_str = base64_str.split(',')[1]
        image_data = base64.b64decode(base64_str)
        # 保存为PNG格式的文件
        prompt_without_sapece = test_prompt.replace(" ", "_")
        source_image = source_image_dir + "{}_{}.png".format(user_token, test_prompt)
        with open(source_image, 'wb') as file:
            file.write(image_data)
        process_image(source_image)
        # 处理风格图像
        styleId = request.json.get('styleId')
        images_list = []
        for id in styleId:
            seed = random.randint(100000,9999999)
            style_image = style_image_dir + "style{}.jpg".format(id)
            Comfyui_api.generate_image(test_prompt, denoising_strength, seed, source_image, style_image, user_token, id, workflowfile)
            imageid = "{}_{}_{}.png".format(user_token, prompt_without_sapece, id)
            url = ENDPOINTS + str(port) + "/" + imageid
            image = Img2Img(url, imageid, id)
            images_list.append(image.to_dict())
        return jsonify(images = images_list)
        # return jsonify(ResponseWrapper.success(jsonify(images = images_list)))

    except BusinessException as be:
        return jsonify(ResponseWrapper.fail(code=be.code, message=be.message))
    except Exception as e:
        return jsonify(ResponseWrapper.fail(code=BUSINESS_FAIL, message=str(e)))


@app.route('/GenerateComponentImage', methods = ['POST'])
def GenerateComponentImage():
    try:
        # 处理用户token
        user_token = str(request.json.get('user_token'))
        # 处理用户输入图片
        imageId = str(request.json.get('imageId'))
        image = output_dir + imageId 
        # 处理用户输入booudingBox
        boundingBox_data = request.json.get('boundingBox')
        # print(boundingBox_data)
        boundingBox = [[[item["coordinate"][0], item["coordinate"][1]], [item["coordinate"][2], item["coordinate"][3]]] for item in boundingBox_data]
        print(boundingBox)
        print(len(boundingBox))
        # 处理用户输入componentCount
        componentCount = int(request.json.get('componentCount'))
        imageId, _= os.path.splitext(imageId)
        # client = Client("http://localhost:8000")
        data = {
            "user_token":user_token,
            "original_image": encode_image(image),
            "componentCount": componentCount,
            "boundingBox": boundingBox,
            "imageId": imageId
        }
        # print(data)
        # data = {
        #     "user_token":"karya",
        #     "original_image": Image.open("/data0/xxl/ProtoFusion/ProtoFusionAPI/source_image/exampleId_car.png"),
        #     "componentCount": 2,
        #     "boundingBox": [[55,60],[100,120]],
        #     "imageId": "exampleId_car_1.png"
        # }
        # 发送请求到DesinEdit服务器
        response = requests.post(DesignEdit_ENDPOINTS, json=data)
        response = response.json()
        # response = client.predict(data)
        return jsonify(response)

    except BusinessException as be:
        return jsonify(ResponseWrapper.fail(code=be.code, message=be.message))
    except Exception as e:
        return jsonify(ResponseWrapper.fail(code=BUSINESS_FAIL, message=str(e)))


@app.route('/GenerateComponent3DModel', methods = ['POST'])
def GenerateComponent3DModel():
    try:
        user_token = str(request.json.get('user_token'))

        componentOrder = str(request.json.get('componentOrder'))

        prompt = str(request.json.get('prompt'))
        resp = Tencentcloud_api.TextTranslate(prompt)
        prompt = json.loads(str(resp.read(),'utf-8')).get('Response').get("TargetText")
        print(prompt)

        imageId = str(request.json.get('imageId'))
        image_dir = output_dir + imageId # Replace with the path to your image
        imageId, _= os.path.splitext(imageId)
        with open(image_dir, 'rb') as image_file:
            image_data = image_file.read()

        # Define the base URL, the API key and Paths
        base_url = "https://hyperhuman.deemos.com/api/v2"
        image_path = image_dir
        result_path = output_dir + imageId.split('/')[0] + "/"
        _, modelId = os.path.split(imageId)
        modelId  = os.path.splitext(modelId)[0] + ".usdz"

        Rodin_api.Generate3DModel(prompt, image_path, result_path, modelId)
        return jsonify(modelId = modelId, url = ENDPOINTS + str(port) + "/" + imageId.split('/')[0] + "/" + modelId)

    except BusinessException as be:
        return jsonify(ResponseWrapper.fail(code=be.code, message=be.message))
    except Exception as e:
        return jsonify(ResponseWrapper.fail(code=BUSINESS_FAIL, message=str(e)))

app.run(host = '0.0.0.0', port=3010)

# test_prompt = """一个无人机""" 
# client_id = 'karya'
# style_list = 

# source_image_dir = "/data0/xxl/ProtoFusion/ProtoFusionAPI/source_image"
# source_image = source_image_dir + "/{}_{}".format(client_id, test_prompt)
# style_image_dir = "/data0/xxl/ProtoFusion/ProtoFusionAPI/style_image"
# style_image = style_image_dir + "/{}_style{}".format(client_id, )
# test_prompt = """一个无人机""" + ''
# seed = random.randint(100000,9999999)

# comfyui_api.generate_image(test_prompt, seed, source_image, style_image, client_id, 1, "/data0/xxl/ProtoFusion/ProtoFusionAPI/workflows/style+img2img_api.json")


