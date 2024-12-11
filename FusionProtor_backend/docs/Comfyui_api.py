import json
import websocket #NOTE: websocket-client (https://github.com/websocket-client/websocket-client)
import uuid
import urllib.request
import urllib.parse
import random
import base64
# from IPython import display

WORKING_DIR='/data0/xxl/ProtoFusion'
# WORKFLOW_FILE='/data0/xxl/ProtoFusion/ProtoFusionAPI/style+img2img_api.json'
COMFYUI_ENDPOINT='127.0.0.1:8188'

server_address = COMFYUI_ENDPOINT
client_id = str(uuid.uuid4())
# client_id = 'karya'




def queue_prompt(prompt, client_id):
    p = {"prompt": prompt, "client_id": client_id}
    data = json.dumps(p).encode('utf-8')
    print(data)
    req =  urllib.request.Request("http://{}/prompt".format(server_address), data=data)
    return json.loads(urllib.request.urlopen(req).read())


def get_image(filename, subfolder, folder_type):
    data = {"filename": filename, "subfolder": subfolder, "type": folder_type}
    url_values = urllib.parse.urlencode(data)
    with urllib.request.urlopen("http://{}/view?{}".format(server_address, url_values)) as response:
        return response.read()

def get_history(prompt_id):
    with urllib.request.urlopen("http://{}/history/{}".format(server_address, prompt_id)) as response:
        return json.loads(response.read())

def get_images(ws, prompt, client_id):
    prompt_id = queue_prompt(prompt, client_id)['prompt_id']
    print(prompt_id)
    output_images = {}
    while True:
        out = ws.recv()
        if isinstance(out, str):
            message = json.loads(out)
            if message['type'] == 'executing':
                data = message['data']
                if data['node'] is None and data['prompt_id'] == prompt_id:
                    break #Execution is done
        else:
            continue #previews are binary data

    history = get_history(prompt_id)[prompt_id]
    for o in history['outputs']:
        for node_id in history['outputs']:
            node_output = history['outputs'][node_id]
            # image branch
            if 'images' in node_output:
                images_output = []
                for image in node_output['images']:
                    image_data = get_image(image['filename'], image['subfolder'], image['type'])
                    images_output.append(image_data)
                output_images[node_id] = images_output
            # video branch
            if 'videos' in node_output:
                videos_output = []
                for video in node_output['videos']:
                    video_data = get_image(video['filename'], video['subfolder'], video['type'])
                    videos_output.append(video_data)
                output_images[node_id] = videos_output

    return output_images

def parse_worflow(ws, prompt, denoising_strength, image, style_image, client_id, seed, workflowfile):
    workflowfile = '{}/workflows/{}'.format(WORKING_DIR, workflowfile)
    # print(workflowfile)
    with open(workflowfile, 'r', encoding="utf-8") as workflow_api_style_img2img_file:
        prompt_data = json.load(workflow_api_style_img2img_file)
        # print(json.dumps(prompt_data, indent=2)

        #set the text prompt for our positive CLIPTextEncode 
         #set the denoising_strength
        prompt_data["12"]["inputs"]["prompt"] = prompt 
        prompt_data["26"]["inputs"]["denoise"] = denoising_strength
        prompt_data["27"]["inputs"]["text"] = prompt 


        #set the source image
        prompt_data["17"]["inputs"]["image"] = image
        #set the style image
        prompt_data["28"]["inputs"]["image"] = style_image

        #set the seed for our KSampler node
        prompt_data["26"]["inputs"]["seed"] = seed
        prompt_data["14"]["inputs"]["seed"] = seed

        return get_images(ws, prompt_data, client_id)
   
# def generate_clip(prompt, image, style_image, seed, idx=1, workflowfile='', client_id):
def generate_image(prompt, denoising_strength, seed, image, style_image, client_id, id, workflowfile=''):
    try:
        # print(seed)
        # print(client_id)
        ws = websocket.WebSocket()
        ws.connect("ws://{}/ws?clientId={}".format(server_address, client_id))
        # prompt
        prompt1 = prompt + ",干净,产品设计,完整视图,白色背景,高清,艺术感,3D渲染,16k,高细节,实物拍摄,逼真,真实产品"
        prompt = prompt.replace(" ", "_")
        images = parse_worflow(ws, prompt1, denoising_strength, image, style_image, client_id, seed, workflowfile)
        # print(images)
        for node_id in images:
            for image_data in images[node_id]:
                from PIL import Image
                import io
                imageid = "{}_{}_{}.png".format(client_id, prompt, id)
                Image_LOCATION = "{}/outputs/{}".format(WORKING_DIR, imageid)
                with open(Image_LOCATION, "wb") as binary_file:
                    # Write bytes to file
                    binary_file.write(image_data)

                
                print("{} DONE!!!".format(Image_LOCATION))
    finally:
        ws.close()
# # ----------
            # im = Image.open(io.BytesIO(image_data))
            # try:
            #     im.save('{}/outputs/picframe{:02d}.png'.format(WORKING_DIR, im.tell()))
            #     while True:
            #         im.seek(im.tell()+1)
            #         im.save('{}/outputs/picframe{:02d}.png'.format(WORKING_DIR, im.tell()))
            # except:
            #     print("处理结束")

            #images[0].save("{}/outputs/{}.gif".format(WORKING_DIR, seed),save_all=True,loop=True,append_images=images[1:],duration=500)

            # image = Image.open(io.BytesIO(image_data))
            # image.save("{}/outputs/{}.gif".format(WORKING_DIR, seed))
            # image.show()
            # display(image) 