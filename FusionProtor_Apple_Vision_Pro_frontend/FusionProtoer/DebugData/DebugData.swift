//
//  DebugData.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/9.
//

import Foundation

let exampleUsdzURL = URL(string: "https://www.apple.com/105/media/us/airpods-3rd-generation/2021/3c0b27aa-a5fe-4365-a9ae-83c28d10fa21/ar/airpods_magsafe_charging_ios15.usdz")

let debug_CandidateEntireImage_json = """
{
  "images":[
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":1
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":2
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":3
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":4
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":5
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":6
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":7
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":8
    },
    {
      "imageId":"20240808_raw_31a4f656",
      "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
      "styleId":9
    }
  ]
}
"""

let debug_GenerateComponentImage_json = """
{
  "componentImages":[
    {
      "tag":"component1",
      "Images":[
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          },
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          }
      ]
    },
    {
      "tag":"component2",
      "Images":[
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          },
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          }
      ]
    },
    {
      "tag":"component3",
      "Images":[
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          },
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          }
      ]
    },
    {
      "tag":"component4",
      "Images":[
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          },
          {
            "imageId":"20240808_raw_31a4f656",
            "url":"https://cdn.pixabay.com/photo/2022/12/28/23/25/car-7683938_1280.jpg",
            "styleId":1
          }
      ]
    }
  ]
}
"""
// let debug_GenerateComponent3DModel_json = """
//{
//  "modelId":"20240808_raw_31a4f656",
//  "url": "https://www.apple.com/105/media/us/airpods-3rd-generation/2021/3c0b27aa-a5fe-4365-a9ae-83c28d10fa21/ar/airpods_magsafe_charging_ios15.usdz"
//}
//"""

let debug_GenerateComponent3DModel_json = """
{
 "modelId":"20240808_raw_31a4f656",
 "url": "http://refinity-protofusion.pub.hsuni.top:29002/exampleId_car_1/karya_component3_1.usdz"
}
"""
