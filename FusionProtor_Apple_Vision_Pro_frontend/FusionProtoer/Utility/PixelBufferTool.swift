//
//  PixelBufferTool.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//
import ARKit
import UIKit

class PixelBufferCache {
    private let cache = NSCache<NSString, CVPixelBuffer>()
 
    func store(pixelBuffer: CVPixelBuffer, forKey key: String) {
        cache.setObject(pixelBuffer, forKey: key as NSString)
    }
 
    func pixelBuffer(forKey key: String) -> CVPixelBuffer? {
        return cache.object(forKey: key as NSString)
    }
}

//// 使用
//let pixelBufferCache = PixelBufferCache()
// 
//// 假设你有一个pixelBuffer和一个key
//if let pixelBuffer = yourPixelBuffer {
//    pixelBufferCache.store(pixelBuffer: pixelBuffer, forKey: "yourKey")
//}
// 
//// 当你需要读取缓存的pixelBuffer时
//if let cachedPixelBuffer = pixelBufferCache.pixelBuffer(forKey: "yourKey") {
//    // 使用你的pixelBuffer
//}




func saveUIImageToFileSystem(image: UIImage, fileName: String) -> URL? {
    let fileManager = FileManager.default
    let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    let imageURL = documentsDirectory.appendingPathComponent(fileName)
    
    if let imageData = image.pngData() {
        try? imageData.write(to: imageURL)
    }
    
    return imageURL
}

//永久储存版本的函数
//func saveUIImageToFileSystem(image: UIImage, fileName: String) -> URL? {
//    let fileManager = FileManager.default
//    let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//    let documentsDirectory = paths[0]
//    let imageURL = documentsDirectory.appendingPathComponent(fileName)
//    
//    if let imageData = image.pngData() {
//        do {
//            try imageData.write(to: imageURL)
//            return imageURL
//        } catch {
//            print("Error saving image: \(error)")
//            return nil
//        }
//    }
//    
//    return nil
//}




//pixelBuffer转为UIImage
func pixelBufferToUIImage(_ pixelBuffer: CVPixelBuffer?) -> UIImage? {
    guard let pixelBuffer = pixelBuffer else {
        return nil
    }

    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext()
    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
        return UIImage(cgImage: cgImage)
    }
    return nil
}

// URL->string(base64)
extension URL {
    func toBase64String() -> String? {
        do {
            let data = try Data(contentsOf: self)
            let base64String = data.base64EncodedString(options: .lineLength64Characters)
            return base64String
        } catch {
            print("Error converting URL to Base64: \(error)")
            return nil
        }
    }
}

//UIImage转为pixelBuffer
extension UIImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)

        var pixelBuffer: CVPixelBuffer?
        let attributes: [NSObject: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]

        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])

        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        guard let cgImage = self.cgImage else {
            return nil
        }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
}
