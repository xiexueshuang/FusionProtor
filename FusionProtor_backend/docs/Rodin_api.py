import time
import os
import requests

Rodin_ENDPOINT = "https://hyperhuman.deemos.com/api/v2/rodin"
Rodin_API_KEY = "3pJffIkgVDa1SK9Ds7M7lQtwp9ZRajwYSR8u5RzHYfsY9gDUhhQcCsC88tGSuKtX"
base_url = "https://hyperhuman.deemos.com/api/v2"
# Prepare the headers.
headers = {
    'Authorization': f'Bearer {Rodin_API_KEY}',
}
# Function to submit a task to the rodin endpoint
def submit_task(image_path, prompt):
    url = f"{base_url}/rodin"
    
    # Read the image file
    with open(image_path, 'rb') as image_file:
        image_data = image_file.read()

    # Prepare the multipart form data
    files = {
        'images': (os.path.basename(image_path), image_data, 'image/jpeg')
    }

    # Set the tier to Rodin Regular
    data = {
        "prompt": prompt,
        "geometry_file_format": "usdz",
        'tier': 'Regular',
        "quality": "high"
    }

    # Note that we are not sending the data as JSON, but as form data.
    # This is because we are sending a file as well.
    response = requests.post(url, files=files, data=data, headers=headers)
    return response.json()

 # Function to check the status of a task
def check_status(subscription_key):
    url = f"{base_url}/status"
    data = {
        "subscription_key": subscription_key
    }
    response = requests.post(url, headers=headers, json=data)
    return response.json()

 # Function to download the results of a task
def download_results(task_uuid):
    url = f"{base_url}/download"
    data = {
        "task_uuid": task_uuid
    }
    response = requests.post(url, headers=headers, json=data)
    return response.json()

def Generate3DModel(prompt, image_path, result_path, modelId):
    headers = {
            "Authorization": f"Bearer {Rodin_API_KEY}",
            "Content-Type": "application/json"
        }

    # Submit the task and get the task UUID
    task_response = submit_task(image_path, prompt)
    print(task_response)
    task_uuid = task_response['uuid']
    subscription_key = task_response['jobs']['subscription_key']

    # Poll the status endpoint every 5 seconds until the task is done
    status = []
    while len(status) == 0 or not all(s['status'] in ['Done', 'Failed'] for s in status):
        time.sleep(5)
        status_response = check_status(subscription_key)
        status = status_response['jobs']
        for s in status:
            print(f"job {s['uuid']}: {s['status']}")

    # Download the results once the task is done
    download_response = download_results(task_uuid)
    download_items = download_response['list']
    # modelId = ”karya_component1_1.usdz“
    # Print the download URLs and download them locally.
    for item in download_items:
        print(f"File Name: {item['name']}, URL: {item['url']}")
        if item['name'] == "base_basic_pbr.usdz":
            dest_fname = os.path.join(result_path, modelId)
            os.makedirs(os.path.dirname(dest_fname), exist_ok=True)
            with open(dest_fname, 'wb') as f:
                response = requests.get(item['url'])
                f.write(response.content)
                print(f"Downloaded {dest_fname}")