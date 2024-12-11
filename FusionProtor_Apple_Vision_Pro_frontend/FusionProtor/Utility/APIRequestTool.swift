//
//  APIRequestTool.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/9.
//

import Foundation

// data object declare
struct ImageData: Codable{
    let imageId: String
    let url: String
    let styleId: Int
    
    init(imageId: String = "", url: String = "", styleId: Int) {
        self.imageId = imageId
        self.url = url
        self.styleId = styleId
    }
}

struct BoundingBoxData: Codable{
    let coordinate:[Int]
}

struct componentImagesData: Codable{
    let tag:String
    let Images:[ImageData]
}


// JSON
func parseJSON<T: Codable>(jsonData: Data, type: T.Type) -> T? {
    let decoder = JSONDecoder()
    
    do {
        let decodedData = try decoder.decode(T.self, from: jsonData)
        return decodedData
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}


/// API:GenerateCandidateEntireImage()

struct GenerateCandidateEntireImage_Response: Codable {
    let images: [ImageData]
}

func GenerateCandidateEntireImage(image: String, styleId: [Int], prompt: String, denoising_strength:Double, user_token: String, completion: @escaping (GenerateCandidateEntireImage_Response?) -> Void) {
    let body = ["image": image, "styleId": styleId, "prompt": prompt, "denoising_strength":denoising_strength, "user_token": user_token] as [String : Any]
    
    sendHTTPRequest(urlString: baseURL + "/GenerateCandidateEntireImage", method: .POST, body: body) { result in
        switch result {
        case .success(let data):
            if let dataString = String(data: data, encoding: .utf8) {
                print("Data received, data:\(dataString)")
            } else {
                print("Failed to convert data to string.")
            }
            if let response: GenerateCandidateEntireImage_Response = parseJSON(jsonData: data, type: GenerateCandidateEntireImage_Response.self) {
                completion(response)
                return
            }
            completion(nil) // 如果解析失败，返回 nil
        case .failure(let error):
            print("Request failed with error: \(error)")
            completion(nil) // 请求失败时返回 nil
        }
    }
}

//func GenerateCandidateEntireImage(image: String, styleId: [Int], prompt: String, user_token: String, completion: @escaping (GenerateCandidateEntireImage_Response?) -> Void) {
//    if let imageDataJsonData = debug_CandidateEntireImage_json.data(using: .utf8){
//        if let response: GenerateCandidateEntireImage_Response = parseJSON(jsonData: imageDataJsonData, type: GenerateCandidateEntireImage_Response.self) {
//            // print("Image ID: \(response.images[0].url)")
//            completion(response)
//        }
//    }
//    completion(nil)
//}







/// API:GenerateComponentImage()



struct GenerateComponentImage_Response: Codable{
    let componentImages: [componentImagesData]
}


func GenerateComponentImage(imageId:String, componentCount:Int, boundingBox:[BoundingBoxData], user_token:String, completion: @escaping (GenerateComponentImage_Response?) -> Void) {

    // 不需要将 boundingBox 转换为字符串
    let body: [String: Any] = [
        "imageId": imageId,
        "componentCount": componentCount,
        "boundingBox": boundingBox.map { $0.dictionaryRepresentation() }, // 转换为字典表示
        "user_token": user_token
    ]
      //这里需要转化为字典是因为BoundingBoxData没有声明为Codable，但是懒得改了。。【Codable 协议是能够完成嵌套数据模型的转换的。需要注意的是，嵌套的数据模型以及嵌套的子模型都必须遵循 Codable 协议】
      //extension BoundingBoxData {
      //  func dictionaryRepresentation() -> [String: Any] {
      //      return ["coordinate": coordinate]
      //  }
      //}


    print(body) // 调试打印

    sendHTTPRequest(urlString: baseURL + "/GenerateComponentImage", method: .POST, body: body) { result in
        switch result {
        case .success(let data):
            print("Data received.")
            
            if let jsonDataString = String(data: data, encoding: .utf8) {
                print("Response data as string: \(jsonDataString)")
            }
            if let response: GenerateComponentImage_Response = parseJSON(jsonData: data, type: GenerateComponentImage_Response.self) {
                completion(response)
                return
            }
            completion(nil) // 如果解析失败，返回 nil
        case .failure(let error):
            print("Request failed with error: \(error)")
            completion(nil) // 请求失败时返回 nil
        }
    }
}

// 在 BoundingBoxData 中添加一个方法，将其转换为字典
extension BoundingBoxData {
    func dictionaryRepresentation() -> [String: Any] {
        return ["coordinate": coordinate]
    }
}


//func GenerateComponentImage(imageId:String, componentCount:Int, boundingBox:[BoundingBoxData], user_token:String, completion: @escaping (GenerateComponentImage_Response?) -> Void) {
//    if let imageDataJsonData = debug_GenerateComponentImage_json.data(using: .utf8){
//        if let response: GenerateComponentImage_Response = parseJSON(jsonData: imageDataJsonData, type: GenerateComponentImage_Response.self) {
//            // print("Image ID: \(response.images[0].url)")
//            completion(response)
//        }
//    }
//    completion(nil)
//}










/// API:GenerateComponent3DModel()
struct GenerateComponent3DModel_Response: Codable{
    let modelId: String
    let url:String
}



func GenerateComponent3DModel(imageId:String, componentOrder:Int, prompt:String, user_token:String,completion: @escaping (GenerateComponent3DModel_Response?) -> Void){
    
//    let body = ["imageId": imageId, "componentOrder": componentOrder, "user_token": user_token] as [String : Any]
    let body = ["imageId": imageId, "prompt":prompt, "user_token": user_token] as [String : Any]
    
    sendHTTPRequest(urlString: baseURL + "/GenerateComponent3DModel", method: .POST, body: body) { result in
        switch result {
        case .success(let data):
            print("Data received.")
            if let response: GenerateComponent3DModel_Response = parseJSON(jsonData: data, type: GenerateComponent3DModel_Response.self) {
                completion(response)
                return
            }
            completion(nil) // 如果解析失败，返回 nil
        case .failure(let error):
            print("Request failed with error: \(error)")
            completion(nil) // 请求失败时返回 nil
        }
    }
}
    
    
//func GenerateComponent3DModel(imageId:String, componentOrder:Int, prompt:String, user_token:String,completion: @escaping (GenerateComponent3DModel_Response?) -> Void){
//    if let imageDataJsonData = debug_GenerateComponent3DModel_json.data(using: .utf8){
//        if let response: GenerateComponent3DModel_Response = parseJSON(jsonData: imageDataJsonData, type: GenerateComponent3DModel_Response.self) {
//            completion(response)
//        }
//    }
//    completion(nil)
//}
