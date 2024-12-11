//
//  SuccessView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI
import RealityKit
import RealityKitContent
import QuickLook

struct ThreeDModelView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var hasFinishedGeneration:Bool = false
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isShowRetry = true
    
    var body: some View {
        VStack{
            ZStack{
                //navigator
                Navigator(onBack: {
                    windowManager.switchWindow(to:.componentImage)
                    windowManager.selectedSkybox = .null
                    Task {
                        await dismissImmersiveSpace()
                    }
                }, onNext: {}, nextDisabled: true, hasNext: false, title: "Check your component model.")
                .onAppear(perform: {
                    for i in 0...windowManager.componentNum-1 {
                        GenerateComponent3DModel(
                            imageId: windowManager.imagesData_component[i][windowManager.componentSelection[i]-1].imageId,
                            componentOrder: i,
                            prompt: windowManager.componentPrompts[i],
                            user_token: windowManager.designID
//                            imageId: "exampleId_car_1/karya_component3_1.png",
//                            componentOrder: i,
//                            user_token: "karya"
                        ){ response in
                            print("生成一个部件3D模型")
                            if(i == windowManager.componentNum-1){
                                hasFinishedGeneration = true
                            }
                            if let response = response {
                                DispatchQueue.main.async {
//                                    print(response.url)
                                    windowManager.UsdzURLs[i] = response.url
                                    windowManager.UsdzIds[i] = response.modelId
                                }
                            } else {
//                                print("Failed to generate 3D model.")
                            }
                        }
                    }
                })
                
                // EnvironmentPicker
                EnvironmentPicker()
                    .padding(.leading,1060)
                    .padding(.top,40)
                    .environmentObject(windowManager)
            }
            
            //content
            VStack {
                // guide title
                if(hasFinishedGeneration){
                    //tip
                    HStack{
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.secondary)
                        Text("You can drag the model out of the window and preview it in space")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom)
                    
                    //3D model display area
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 80){
                            Spacer()
                            ForEach(0..<windowManager.componentNum, id: \.self) { i in
                                VStack{
                                    ComponentModelViewer(
                                        url: windowManager.UsdzURLs[i], order: i + 1,
                                        isShowRetry: $isShowRetry
                                    )
                                    .environmentObject(windowManager)
                                    // debug info
//                                    Text(windowManager.UsdzIds[i])
                                }
                                
                            }
                            Spacer()
                        }
                    }

                    //tail guide
                    if(hasFinishedGeneration){
                        HStack{
                            Image("blenderLogo")
                                .frame(width: 64)
                            VStack(alignment: .leading) {
                                Text("Move on your work in Blender.")
                                Text("Click “import” in plugin to import all components at once")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical,40)
                    }

                }
                else{
                    VStack{
                        Spacer()
                        ProgressView()
                        Text("Waiting for generating 3D model...")
                        Text("About 3 minites left")
                        Spacer()
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
    

}

func downloadModel(from url: URL, completion: @escaping (URL?) -> Void) {
    let task = URLSession.shared.downloadTask(with: url) { (tempFileURL, response, error) in
        guard let tempFileURL = tempFileURL, error == nil else {
            print("Error downloading model: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        // Move the file to a permanent location if needed
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let permanentURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        do {
            if fileManager.fileExists(atPath: permanentURL.path) {
                try fileManager.removeItem(at: permanentURL)
            }
            try fileManager.moveItem(at: tempFileURL, to: permanentURL)
            DispatchQueue.main.async {
                completion(permanentURL)
            }
        } catch {
            print("Error moving model file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    task.resume()
}

struct ComponentModelViewer: View{
    @State var url:String
    var order:Int
    @State private var session:PreviewSession?
    @State private var isOpened = false
    @State private var downloadedURL: URL? = nil
    @Binding var isShowRetry:Bool
    @EnvironmentObject var windowManager: WindowManager
    
    var body: some View {
        VStack{
            Text("Component" + String(order))
                .font(.title)
                .padding()
                .onAppear {
                    
                    DispatchQueue.main.async {
                        url = windowManager.UsdzURLs[order-1]
                        print("获取URL：", windowManager.UsdzURLs[order-1])
                        
                        if let url = URL(string: url){
                            downloadModel(from: url) { url in
                                if let url = url {
                                    print("【拖动】下载至本地完成 url:\(url)")
                                    downloadedURL = url
                                }
                            }
                        }
                    }

                }
            
            
            if let url = URL(string: url){
//                Text(downloadedURL?.absoluteString ?? "no")
                Model3D(url: url){ model in
                     model
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 300,height: 200)
                         .onDrag({
                             if let downloadedURL = downloadedURL{
                                 return NSItemProvider(contentsOf: downloadedURL,contentType: .usdz)
                             }
                             return NSItemProvider()
                         })
                         
                 } placeholder: {
                     VStack{
                         ProgressView()
                         Text("Downloading...")
                     }
                     .frame(width: 300,height: 200)
                 }
            }else{
                VStack{
                    ProgressView()
                    Text("Getting resources...")
                    if(isShowRetry){
                        Button(action:{
                            url = windowManager.UsdzURLs[order-1]
                            print(windowManager.UsdzURLs[order-1])
//                            isShowRetry = false
                        }){
                            Text("Retry")
                        }
                    }

                }
                .frame(width: 300,height: 200)
            }
            

    
            HStack{
                
                //quicklook button
//                Button(action: {
//                    let previewItem = PreviewItem(
//                        url:url,
//                        displayName: "Component Detail",
//                        editingMode: .disabled
//                    )
//                    session = PreviewApplication.open(items: [previewItem])
//                    observeSessionEvent()
//                }){
//                    Image(systemName: "eye")
//                        .font(.title)
//                        .frame(width: 32, height: 64)
//                }
//                .disabled(isOpened)
                
                //regenerate button
                ButtonWithIcon(onBack: {
                    //regenerate()
                }, iconName: "gobackward", text: "Regenerate")
                .padding()
                .disabled(true)
            }
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
                    isOpened = true
                    break
                case .didClose:
                    isOpened = false
                    break
                case.didFail:
                    isOpened = false
                    break;
                default:
                    break;
                }
            }
        }
    }
}

enum Skybox: String, CaseIterable, Identifiable {
    case mountain, shanghai, space, null
    var id: Self { self }
}


struct EnvironmentPicker:View{
    @EnvironmentObject var windowManager: WindowManager
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View{
        Menu {
            Button(action: {
                Task {
                    if( windowManager.selectedSkybox != .null){
                        await dismissImmersiveSpace()
                    }
                    _ = await openImmersiveSpace(id: "mountain")
                    windowManager.selectedSkybox = .mountain
                }
            }) {
                HStack{
                    Text("Mountain")
                    Image(systemName: "mountain.2")
                }
            }
            .disabled(windowManager.selectedSkybox == .mountain)
            
            Button(action: {
                Task {
                    if(windowManager.selectedSkybox != .null){
                        await dismissImmersiveSpace()
                    }
                    _ = await openImmersiveSpace(id: "shanghai")
                    windowManager.selectedSkybox = .shanghai
                }
            }) {
                HStack{
                    Text("Shanghai")
                    Image(systemName: "building.2.fill")
                }
            }
            .disabled(windowManager.selectedSkybox == .shanghai)
            
            Button(action: {
                Task {
                    if(windowManager.selectedSkybox != .null){
                        await dismissImmersiveSpace()
                    }
                    _ = await openImmersiveSpace(id: "space")
                    windowManager.selectedSkybox = .space
                }
            }) {
                HStack{
                    Text("Space")
                    Image(systemName: "globe.europe.africa")
                }
            }
            .disabled(windowManager.selectedSkybox == .space)
            
            Button(action: {
                windowManager.selectedSkybox = .null
                Task {
                    await dismissImmersiveSpace()
                }
            }) {
                HStack{
                    Text("Restore")
                    Image(systemName: "arrow.uturn.backward")
                }
            }
            .disabled(windowManager.selectedSkybox == .null)
            
            
            
        } label: {
            Image(systemName: "mountain.2")
                .font(.title)
                .padding()
                .padding(.horizontal,-20)
        }
    }
}
#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    ThreeDModelView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
