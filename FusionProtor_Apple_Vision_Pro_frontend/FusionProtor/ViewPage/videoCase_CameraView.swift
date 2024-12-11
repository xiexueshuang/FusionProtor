//
//  ContentView.swift
//  test
//
//  Created by 蒋招衢 on 2024/7/3.
//

import SwiftUI
import ARKit
import AVFoundation

struct videoCase_CameraView: View {
    @EnvironmentObject var windowManager: WindowManager
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isTapped = false
    var body: some View {
        VStack{
            //navigator
            Navigator(onBack: {
                windowManager.switchWindow(to:.designId)
            }, onNext: {
                
            }, nextDisabled: true, hasNext: false, title: "Take a photo.")

            //content
            VStack {
                //image area
                if let uiImage = pixelBufferToUIImage(windowManager.capturedImagePixelBuffer) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 640,height: 360)
                        .cornerRadius(12)
                        .padding()
                    
                } else {
                    ZStack{
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.thickMaterial)
                            .frame(width: 640, height: 360)
                            .cornerRadius(12)
                            .padding()
                        Text("Unable to access main camera")
                    }
                }
                
                HStack{
                    // capture button
                    ButtonWithIcon(onBack: {
                        isTapped = true;
                        AudioServicesPlaySystemSound(1108) // 1108 拍照快门声
                        Task{
                            await dismissImmersiveSpace()
                            windowManager.switchWindow(to: .edit)
                            windowManager.modifiedImageURL = nil
                            guard let uiImage = UIImage(named: "videoCase_image") else {
                                print("Failed to load image")
                                return
                            }
                            windowManager.capturedImagePixelBuffer = uiImage.toPixelBuffer()
                        }
                    }, iconName: "camera", text: "Capture")
                    .padding()
                    .disabled(windowManager.capturedImagePixelBuffer == nil || isTapped)
                    
                    if(isTapped){
                        ProgressView()
                    }
                    
                    // capture button
//                    ButtonWithIcon(onBack: {
//                        loadFakeImage(named:"exampleCase")
//                    }, iconName: "photo.badge.plus", text: "[Dubug] Load image")
//                    .padding()
                }
                
            }
            .padding()
            Spacer()
        }
        // 一进入页面就申请摄像头权限
        .onAppear {
            isTapped = false
            windowManager.reset()
            Task{
                await requestCameraAccess()
            }
        }
    }
    

    
    var arKitSession = ARKitSession()
    
    func requestCameraAccess() async {
        
        guard CameraFrameProvider.isSupported else{
            print("不支持CameraFrameProvider")
            return
        }
        
        // camera type
        let formats = CameraVideoFormat.supportedVideoFormats(for: .main, cameraPositions: [.left])
        let cameraFrameProvider = CameraFrameProvider()
                
        // main camera feed access example
        let cameraAuthorization = await arKitSession.queryAuthorization(for: [.cameraAccess])

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
            print("arKitSession异常")
            return
        }

        print("开启arKitSession")
                
        guard let cameraFrameUpdates = cameraFrameProvider.cameraFrameUpdates(for: formats[0]) else {
            print("摄像头cameraFrameprovider更新异常")
            return
        }
        
        // read camera frame and store it to buffer
        for await cameraFrame in cameraFrameUpdates {
//            print(cameraFrame)
            guard let mainCameraSample = cameraFrame.sample(for:.left) else {
                print("摄像头 mainCameraSample异常")
                continue
            }
//            print("更新摄像头画面")
            windowManager.capturedImagePixelBuffer = mainCameraSample.pixelBuffer
        }
        
    }
    
    func loadFakeImage(named: String){
        print("load Fake Image")
        guard let uiImage = UIImage(named: named) else {
            print("Failed to load image")
            return
        }
        windowManager.capturedImagePixelBuffer = uiImage.toPixelBuffer()
    }
    
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    videoCase_CameraView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}



