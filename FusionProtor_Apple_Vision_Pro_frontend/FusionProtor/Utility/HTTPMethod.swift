//
//  HTTPMethod.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/12.
//


import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

let baseURL = "http://refinity-protofusion.pub.hsuni.top:29002"
func sendHTTPRequest(
    urlString: String,
    method: HTTPMethod,
    headers: [String: String]? = nil,
    body: [String: Any]? = nil,
    completion: @escaping (Result<Data, Error>) -> Void
) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.timeoutInterval = 999.0 // Set the timeout interval (in seconds)
    
    // 添加请求头
    if let headers = headers {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    // 设置请求体
    if let body = body {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Error serializing JSON body: \(error)")
            completion(.failure(error))
            return
        }
    }
    
    // 发送请求
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("No data received")
            return
        }
        
        completion(.success(data))
    }
    
    task.resume()
}

//// 使用示例：GET 请求
//sendHTTPRequest(urlString: "https://api.example.com/data", method: .GET) { result in
//    switch result {
//    case .success(let data):
//        print("Received data: \(data)")
//        // 你可以在此处处理数据，例如将其转换为字符串或 JSON 对象
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Response JSON: \(jsonString)")
//        }
//    case .failure(let error):
//        print("Request failed with error: \(error)")
//    }
//}
//
//// 使用示例：POST 请求
//let body = ["key": "value"]
//sendHTTPRequest(urlString: "https://api.example.com/submit", method: .POST, body: body) { result in
//    switch result {
//    case .success(let data):
//        print("Received data: \(data)")
//    case .failure(let error):
//        print("Request failed with error: \(error)")
//    }
//}
