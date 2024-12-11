//
//  cameraTest.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/15.
//

import SwiftUI
import ARKit

struct CameraTestView: View {
    
    @State var pixelBuffer: CVPixelBuffer?
    var body: some View {
        VStack{
            Button(action:{
                Task {
                    await loadCameraFeed()
                }
            }){
                Text("test")
            }
            if let pixelBuffer = pixelBuffer {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext(options: nil)
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    Image(uiImage: UIImage(cgImage: cgImage))
                }
            }else{
                Image("exampleCase")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 400,height: 400)
            }
        }
    }
    
    func loadCameraFeed() async {
        // Main Camera Feed Access Example
        let formats = CameraVideoFormat.supportedVideoFormats(for: .main, cameraPositions:[.left])
        let cameraFrameProvider = CameraFrameProvider()
        let arKitSession = ARKitSession()
        
        // main camera feed access example
        var cameraAuthorization = await arKitSession.queryAuthorization(for: [.cameraAccess])

        guard cameraAuthorization == [ARKitSession.AuthorizationType.cameraAccess:ARKitSession.AuthorizationStatus.allowed] else {
            if cameraAuthorization == [ARKitSession.AuthorizationType.cameraAccess:ARKitSession.AuthorizationStatus.denied] {
                print("用户已经拒绝了摄像头权限。请到设置中开启。")
            }else if cameraAuthorization == [ARKitSession.AuthorizationType.cameraAccess:ARKitSession.AuthorizationStatus.notDetermined] {
                print("用户还未决定授权")
            }
            return
        }
        
        do {
            try await arKitSession.run([cameraFrameProvider])
        } catch {
            return
        }
        
        let cameraFrameUpdates = cameraFrameProvider.cameraFrameUpdates(for: formats[0])
        
        if cameraFrameUpdates != nil  {
            print("identify cameraFrameUpdates")
        } else{
            print("fail to get cameraFrameUpdates")
            return
        }
        
        for await cameraFrame in cameraFrameUpdates! {
            
            print(cameraFrame)
            
            guard let mainCameraSample = cameraFrame.sample(for: .left) else {
                continue
            }
            pixelBuffer = mainCameraSample.pixelBuffer
        }
    }
}

#Preview(windowStyle: .automatic) {
    CameraTestView()
}
