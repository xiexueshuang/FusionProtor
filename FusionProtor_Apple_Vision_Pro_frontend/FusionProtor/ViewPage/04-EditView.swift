//
//  EditView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI
import QuickLook

struct EditView: View {
    @EnvironmentObject var windowManager: WindowManager
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    //quicklook object
    @State private var showQuickLook = false
    @State var imageURL: URL? = nil
    @State private var session:PreviewSession?
    @State var isOnEdit = false
    
    var body: some View {
        VStack{
            
            //navigator
            Navigator(onBack: {
                windowManager.switchWindow(to:.camera)
                Task {
                    _ = await openImmersiveSpace(id: "camera")
                }
            }, onNext: {
                windowManager.switchWindow(to:.prompt)
                // 用户未作编辑直接跳过
                guard let _ = windowManager.modifiedImageURL else{
                    print("用户未作编辑直接跳过")
                    if let uiImage = pixelBufferToUIImage(windowManager.capturedImagePixelBuffer){
                        windowManager.modifiedImageURL = saveUIImageToFileSystem(
                            image: uiImage,
                            fileName: "previewImage.png"
                        )
                    }
                    return
                }
            }, nextDisabled: isOnEdit, title: "Edit your photo.")
            .onAppear(perform: {
                // 已存在编辑过图像的数据
                if let modifiedImageURL = windowManager.modifiedImageURL {
                    imageURL = modifiedImageURL
                    print("已存在编辑过图像的数据")
                }
                // 未存在编辑过图像的数据，加载原始拍摄数据
                else if let uiImage = pixelBufferToUIImage(windowManager.capturedImagePixelBuffer){
                    imageURL = saveUIImageToFileSystem(
                        image: uiImage,
                        fileName: "previewImage.png"
                    )
                    print("未存在编辑过图像的数据，加载原始拍摄数据")
                }
            })
            
            //content
            VStack {
                Spacer()
                ZStack{
                    // onEdit tip
                    if(isOnEdit){
                        VStack(spacing: 20){
                            Text("Edit your photo in the new window.")
                                .font(.title)
                            Text("1. Start diting: Click the File icon, and choose \"Mark up\".")
                            Text("2. End editing: close the edit window and get back.")
                        }
                        .frame(width: 640, height: 360)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                    }else{
                        //image area
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 640, height: 360)
                                        .cornerRadius(12)
                                        .padding()
                                case .failure:
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(.thickMaterial)
                                            .frame(width: 640, height: 360)
                                            .cornerRadius(12)
                                            .padding()
                                            .padding(.bottom, 40)
                                        Text("Unable to get photo")
                                    }
                                @unknown default:
                                    EmptyView()
                            }
                        }
                    }
                }
                
                // edit button
                ButtonWithIcon(onBack: {
                    
                    // let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
                    
                    if let image = pixelBufferToUIImage(windowManager.capturedImagePixelBuffer){
                        imageURL = saveUIImageToFileSystem(image: image, fileName: "previewImage.png")
                        
                        // print(imageURL?.absoluteString)
                        // file:///Users/jiangzhaoqu/Library/Developer/CoreSimulator/Devices/06D12651-000F-4885-BE9C-1B2ADD97C00C/data/Containers/Data/Application/BBD49D7A-1B32-4C49-B132-EB98D9EE4436/Library/Caches/previewImage.png
                        let previewItem = PreviewItem(
                            url: imageURL!,
                            displayName: "Edit captured photo",
                            editingMode: .updateContents
                        )
                        session = PreviewApplication.open(items: [previewItem])
                        observeSessionEvent()
                    }
                    
                }, iconName: "pencil.and.outline", text: "Edit")
                .padding()
//                .quickLookPreview($documentUrl)
                Spacer()
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func observeSessionEvent(){
        guard let session else {
            print("quicklookSession 异常退出")
            return
        }
        Task{
            for await event in session.events{
                switch event{
                case.didOpen:
                    isOnEdit = true
                    break
                case .didClose:
                    isOnEdit = false
                    windowManager.modifiedImageURL = imageURL
                    break
                case.didFail:
                    isOnEdit = false
                    windowManager.modifiedImageURL = imageURL
                    break;
                default:
                    break;
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    EditView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
